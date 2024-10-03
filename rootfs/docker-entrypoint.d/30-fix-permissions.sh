#!/bin/sh
# Script to fix file permissions. Loaded during Docker entrypoint.
set -eu

chown -R ${CGIT_APP_USER}:${CGIT_APP_USER} /opt/git/ \
                     /opt/cgit/ \
                     /run/fcgiwrap/

chmod 770 /opt/cgit/ \
          /opt/cgit/ \
          /opt/cgit/filters/ \
          /opt/cgit/app/ \
          /opt/cgit/cache/ \
          /opt/git/

chmod u+x /opt/cgit/app/cgit.cgi
