#!/bin/bash

echo "Starting up Screenly..."

# By default docker provides 64MB of shared memory size but heavy pages might need more
umount /dev/shm && mount -t tmpfs shm /dev/shm

# Create folders in /data if needed and copy default files
if [ ! -d "$SCREENLY_HOME" ]; then
    echo "SCREENLY_HOME at ${SCREENLY_HOME} does not exists, setting up"
    mkdir -p "${SCREENLY_HOME}"
    mkdir "${SCREENLY_HOME}/screenly"
    mkdir "${SCREENLY_HOME}/.screenly"
    mkdir "${SCREENLY_HOME}/screenly_assets"
    mkdir -p "${SCREENLY_HOME}/.config/uzbl"
    cp -n screenly.conf "${SCREENLY_HOME}/.screenly/screenly.conf"
    cp -n screenly/ansible/roles/screenly/files/screenly.db "${SCREENLY_HOME}/.screenly/screenly.db"
    cp -n screenly/loading.png "${SCREENLY_HOME}/screenly/loading.png"
    cp -n screenly/ansible/roles/screenly/files/uzbl-config "${SCREENLY_HOME}/.config/uzbl/config-screenly"
    # set the permissions right
    chown -R pi:pi "${SCREENLY_HOME}"
else
    echo "SCREENLY_HOME at ${SCREENLY_HOME} already exists"
fi

# Start services after everything's set up
systemctl start X.service
systemctl start matchbox.service
systemctl start screenly-viewer.service
systemctl start screenly-web.service
systemctl start screenly-websocket_server_layer.service

if [ -n "$DEBUG" ]; then
    journalctl --follow --all --output=short
fi
