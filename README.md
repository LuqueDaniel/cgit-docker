# Cgit Docker

[![GitHub](https://img.shields.io/github/license/LuqueDaniel/cgit-docker?style=flat-square)](https://github.com/LuqueDaniel/cgit-docker/blob/main/LICENSE)

Docker image for [Cgit](https://git.zx2c4.com/cgit/about/) a web interface for [Git](https://git-scm.com/) repositories.

The image compiles and deploys Cgit with Nginx and fcgiwrap.

To run it:

```bash
docker compose up
```

And then open the URL `localhost:8082`. If you want to customize the compilation, installation or configuration, edit the corresponding files.

## Cgit configuration

* You can check and edit the Cgit configuration of the image in the [`cgitrc`](https://github.com/LuqueDaniel/cgit-docker/blob/main/cgitrc) file.
* The Nginx configuration is in the [`cgit_nginx.conf`](https://github.com/LuqueDaniel/cgit-docker/blob/main/) file.
* [`cgit_build.conf`](https://github.com/LuqueDaniel/cgit-docker/blob/main/cgit_build.conf) contains environment variables for Cgit compilation. You need to edit it if you want to use different paths.

If you want to use your own settings you can mount your `cgitrc` file as follows.

```yml
services:
  cgit:
    hostname: cgit
    image: cgit:latest
    build: .
    ports:
      - "8080:80"
    restart: on-failure:5
    volumes:
        - type: bind
          source: ./path/to/cgitrc
          target: /opt/cgit/cgitrc
```

The Cgit `scan-path` configuration parameter is set to read repositories from the `/opt/git` path. That path can be mounted as a volume.

```yml
    volumes:
      - git-vlume:/opt/git/
```

## How To add Basic Auth and allow push
This example show how to add basic auth (and allow push changes) to you cgit server.

```sh
# up example [docker-compose.auth-example.yml] configuration
docker compose -f docker-compose.auth-example.yml down -v && docker compose -f docker-compose.auth-example.yml up --build

# clone repo as root
docker compose -f docker-compose.auth-example.yml exec cgit git clone --bare https://github.com/nginx/nginx.git /opt/git/nginx.git

# setup permission to allow write by fcgiwrap process
docker compose -f docker-compose.auth-example.yml exec cgit chown -R nginx:nginx /opt/git/nginx.git

# clone repo (use: dev / 123), make some changes and push back
git clone http://localhost:8082/nginx /tmp/nginx-cloned
echo "CHANGED" >> /tmp/nginx-cloned/README.md
(cd /tmp/nginx-cloned && git add . && git commit -m 'changed' && git push)
```

## References
* [Cgit README](https://git.zx2c4.com/cgit/tree/README)
* [Cgit configuration](https://git.zx2c4.com/cgit/tree/cgitrc.5.txt)
* [cgit - ArchWiki](https://wiki.archlinux.org/title/Cgit)
