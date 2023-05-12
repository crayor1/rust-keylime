#!/bin/bash
################################################################################
# SPDX-License-Identifier: Apache-2.0
################################################################################

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Creating keylime user if it not exists"
if ! getent passwd keylime >/dev/null; then
    adduser --system --shell /bin/false \
            --home /var/lib/keylime --no-create-home \
            keylime
fi

echo "Changing files to be owned by the keylime user"
# Create all directories required if not there
mkdir -p /var/lib/keylime
mkdir -p /var/log/keylime
mkdir -p /var/run/keylime

chown keylime:keylime -R /etc/keylime
chown keylime:keylime -R /var/lib/keylime
chown keylime:keylime -R /var/log/keylime
chown keylime:keylime -R /var/run/keylime

chmod 700 /var/run/keylime

