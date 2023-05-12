#!/bin/bash
# If all else fails, assume they already have Keylime (we're in it!)
if [[ -z "$KEYLIME_DIR" ]] ; then
    KEYLIME_DIR=`pwd`
fi


# Sanity check
if [[ ! -d "$KEYLIME_DIR/scripts" || ! -d "$KEYLIME_DIR/keylime" ]] ; then
    echo "ERROR: Invalid keylime directory at $KEYLIME_DIR"
    exit 1
fi

echo
echo "=================================================================================="
echo $'\t\t\t\tBuild and install configuration'
echo "=================================================================================="

mkdir -p /etc/keylime
mkdir -p config
python3 -m keylime.cmd.convert_config --defaults --out config --templates templates

for comp in "agent" "verifier" "tenant" "registrar" "ca" "logging"; do
    mkdir -p /etc/keylime/$comp.conf.d
    if [[ -f "/etc/keylime/$comp.conf" ]] ; then
        if [[ $(diff -N "/etc/keylime/$comp.conf" "config/$comp.conf") ]] ; then
            echo "Modified $comp.conf found in /etc/keylime, creating /etc/keylime/$comp.conf.new instead"
            cp "config/$comp.conf" "/etc/keylime/$comp.conf.new"
            chmod 600 /etc/keylime/$comp.conf.new
        fi
    else
        echo "Installing $comp.conf to /etc/keylime"
        cp -n "config/$comp.conf" "/etc/keylime/"
        chmod 600 "/etc/keylime/$comp.conf"
    fi
done

# Install templates for configuration upgrades
mkdir -p /usr/share/keylime/
cp -r templates /usr/share/keylime/templates

echo
echo "=================================================================================="
echo $'\t\t\t\tCheck for tpm_cert_store'
echo "=================================================================================="
if [ ! -d "/var/lib/keylime/tpm_cert_store" ]; then
  echo "Creating new tpm_cert_store"
  mkdir -p /var/lib/keylime
  cp -r $KEYLIME_DIR/tpm_cert_store /var/lib/keylime/tpm_cert_store
else
  echo "Updating existing cert store"
  cp -n $KEYLIME_DIR/tpm_cert_store/* /var/lib/keylime/tpm_cert_store/
fi
