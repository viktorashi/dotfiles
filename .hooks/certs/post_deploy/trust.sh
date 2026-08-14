#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo."
  exit 1
fi

CERTS_DIR="$HOME/.dotfiles/files/certs"
echo "Installing custom certificates from $CERTS_DIR..."

# Check if there are any certs to install
if ! ls "$CERTS_DIR"/*.crt 1> /dev/null 2>&1; then
    echo "No .crt files found in $CERTS_DIR. Skipping."
    exit 0
fi

if [ -d /etc/ca-certificates/trust-source/anchors ]; then
    # Arch Linux / Manjaro
    cp "$CERTS_DIR"/*.crt /etc/ca-certificates/trust-source/anchors/
    update-ca-trust
elif [ -d /usr/local/share/ca-certificates ]; then
    # Ubuntu / Debian
    cp "$CERTS_DIR"/*.crt /usr/local/share/ca-certificates/
    update-ca-certificates
else
    echo "Unsupported OS for automatic certificate installation."
    exit 1
fi

echo "Certificates installed successfully! You may need to restart your terminal."
