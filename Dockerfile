# Image to build cgit
FROM alpine:latest AS build

ARG CGIT_REPO_URL=https://git.zx2c4.com/cgit

# To avoid conflict: undeclared REG_STARTEND compiling git with musl
# https://github.com/git/git/blob/23b219f8e3f2adfb0441e135f0a880e6124f766c/git-compat-util.h#L1279-L1281
ENV NO_REGEX=NeedsStartEnd

RUN apk add --no-cache \
    git \
    make \
    gcc \
    musl-dev \
    musl-libintl \
    openssl-dev \
    zlib-dev \
    luajit

RUN git clone --depth 1 $CGIT_REPO_URL /opt/cgit-repo
WORKDIR /opt/cgit-repo
COPY ["cgit_build.conf", "/opt/cgit-repo/cgit.conf"]
RUN git submodule init && git submodule update
RUN make && make install


# Image to run cgit with NGINX and fcgiwrap
FROM nginx:alpine

ARG CGIT_CACHE_PATH=/opt/cgit/cache

RUN apk add --no-cache \
    fcgiwrap \
    git \
    groff \
    python3 \
    py3-pip \
    py3-pygments \
    py3-markdown \
    luajit \
    && ln -sf python3 /usr/bin/python \
    && python -m pip install rst2html

# Nginx cgit config
COPY ["cgit_nginx.conf", "/etc/nginx/conf.d/default.conf"]

# Cgit setup
COPY --from=build /opt/cgit /opt/cgit
COPY ["cgitrc", "/opt/cgit/"]
COPY ["./filters/html-converters/rst2html", "/opt/cgit/filters/html-converters/"]
RUN mkdir -p $CGIT_CACHE_PATH

COPY ["40-fcgiwrap.sh", "/docker-entrypoint.d/"]
VOLUME ["/opt/git"]
EXPOSE 80
