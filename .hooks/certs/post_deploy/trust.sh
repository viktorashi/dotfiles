#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo."
  exit 1
fi

CERTS_DIR="$HOME/.dotfiles/files/certs"
echo "Installing custom certificates from $CERTS_DIR..."

# Check if there are any certs to install
shopt -s nullglob
cert_files=("$CERTS_DIR"/*.crt "$CERTS_DIR"/*.pem)
shopt -u nullglob

if [ ${#cert_files[@]} -eq 0 ]; then
  echo "No certificate files found in $CERTS_DIR. Skipping."
  exit 0
fi

if [ -d /etc/ca-certificates/trust-source/anchors ]; then
  # Arch Linux / Manjaro
  for cert in "${cert_files[@]}"; do
    base_name=$(basename "$cert")
    name_no_ext="${base_name%.*}"
    cp "$cert" "/etc/ca-certificates/trust-source/anchors/${name_no_ext}.crt"
  done
  update-ca-trust
elif [ -d /usr/local/share/ca-certificates ]; then
  # Ubuntu / Debian
  for cert in "${cert_files[@]}"; do
    base_name=$(basename "$cert")
    name_no_ext="${base_name%.*}"
    cp "$cert" "/usr/local/share/ca-certificates/${name_no_ext}.crt"
  done
  update-ca-certificates
else
  echo "Unsupported OS for automatic certificate installation."
  exit 1
fi

echo "Certificates installed successfully! You may need to restart your terminal."
