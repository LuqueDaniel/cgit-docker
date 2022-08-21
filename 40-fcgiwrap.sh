#!/bin/sh
# Script to start a fcgiwrap socket. Loaded during Docker entrypoint.
SOCKET_PATH=/run/fcgiwrap/fcgiwrap.sock

echo "Starting fcgiwrap..."
if [ -e "$SOCKET_PATH" ]; then
    echo "Removing previous socket: $SOCKET_PATH"
    rm $SOCKET_PATH
fi

echo "Waiting for fcgiwrap to create a socket..."
/usr/bin/fcgiwrap -s unix:$SOCKET_PATH &
while [ ! -e "$SOCKET_PATH" ]; do
    sleep 2
done
chmod 766 $SOCKET_PATH

exit 0;
