#!/bin/bash

echo "Starting up Screenly..."

# By default docker provides 64MB of shared memory size but heavy pages might need more
umount /dev/shm && mount -t tmpfs shm /dev/shm

# Create folders in /data if needed and copy default files
if [ ! -d "${SCREENLY_HOME}" ]; then
    echo "SCREENLY_HOME at ${SCREENLY_HOME} does not exists, setting up."
    mkdir -p "${SCREENLY_HOME}"
    mkdir "${SCREENLY_HOME}/screenly"
    mkdir "${SCREENLY_HOME}/.screenly"
    mkdir "${SCREENLY_HOME}/screenly_assets"
    mkdir -p "${SCREENLY_HOME}/.config/uzbl"
    cp screenly/ansible/roles/screenly/files/screenly.db "${SCREENLY_HOME}/.screenly/screenly.db"
    cp screenly/loading.png "${SCREENLY_HOME}/screenly/loading.png"
    cp screenly/ansible/roles/screenly/files/uzbl-config "${SCREENLY_HOME}/.config/uzbl/config-screenly"
    # set the permissions right
    chown -R pi:pi "${SCREENLY_HOME}"
else
    echo "SCREENLY_HOME at ${SCREENLY_HOME} already exists"
    if [ -n "${OVERWRITE_CONFIG}" ]; then
        echo "Requested to overwrite Screenly config file."
        cp screenly.conf "${SCREENLY_HOME}/.screenly/screenly.conf"
    fi
fi

# Set management page's user and password from environment variables,
# but only if both of them are provided. Can have empty values provided.
if [ -n "${MANAGEMENT_USER+x}" ] && [ -n "${MANAGEMENT_PASSWORD+x}" ]; then
    sed -i -e "s/^user = .*/user = ${MANAGEMENT_USER}/" -e "s/^password = .*/password = ${MANAGEMENT_PASSWORD}/" "${SCREENLY_HOME}/.screenly/screenly.conf"
fi

# Start services after everything's set up
systemctl start X.service
systemctl start matchbox.service
systemctl start screenly-viewer.service
systemctl start screenly-web.service
systemctl start screenly-websocket_server_layer.service

# If extra debug information is required in the console, then show the container's
# journal in the logs by setting the `DEBUG` environment variable to anything.
if [ -n "${DEBUG}" ]; then
    journalctl --follow --all --output=short
fi

# If device public URL is set up, port 80 has to be redirected to 8080 where the
# management interface runs.
# If that redirection is not required, then can set `NO_PORT_FORDWARD` environemt
# variable to disable this.
function remove_port_forwarding {
    echo "Cleaning up port forwarding."
    iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
}
if [ -z "${NO_PORT_FORDWARD}" ]; then
    # Setting up redirect of port 80 to 8080, so the device can be managed remotely
    echo "Setting up port forwarding."
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
    # Clean u
    trap 'remove_port_forwarding' SIGINT SIGTERM
fi

# Idle so not to exit
while : ; do
    sleep 600;
done
