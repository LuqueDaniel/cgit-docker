ARG ALPINE_VERSION=3.22
ARG CGIT_VERSION=09d24d7cd0b7e85633f2f43808b12871bb209d69
ARG NGINX_VERSION=1.29.3

FROM alpine:${ALPINE_VERSION} AS build
ARG CGIT_VERSION

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
    luajit-dev


WORKDIR /opt/cgit-repo
RUN git clone https://git.zx2c4.com/cgit . \
 && git checkout ${CGIT_VERSION} \
 && git submodule update --init --recursive

COPY ["cgit_build.conf", "/opt/cgit-repo/cgit.conf"]
RUN make && make install


FROM nginx:${NGINX_VERSION}-alpine${ALPINE_VERSION}


# mailcap - provides /etc/mime.types
RUN apk add --no-cache \
    fcgiwrap \
    git \
    git-daemon \
    groff \
    python3 \
    py3-pip \
    py3-pygments \
    py3-markdown \
    luajit \
    lua5.1-http \
    mailcap \
    && ln -sf python3 /usr/bin/python \
    && python -m pip install --no-cache-dir --break-system-packages rst2html \
    && rm -rf ${HOME}/.cache/*

ENV CGIT_APP_USER=nginx

COPY ./rootfs/ /
COPY --from=build /opt/cgit /opt/cgit

VOLUME ["/opt/git"]
EXPOSE 80
