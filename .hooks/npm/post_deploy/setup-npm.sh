#!/bin/bash

echo "Configuring NPM and PNPM registry and CA certificates..."

# Set registry for Artifactory
npm config set registry https://artifactory.intern.stratec.com/artifactory/api/npm/NpmBuild/ --global

# Set CA file based on OS
if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
  # Linux (Ubuntu/Debian/Arch)
  npm config set cafile "/etc/ssl/certs/ca-certificates.crt" --global
elif [ -n "$WINDIR" ] || [[ "$(uname -r)" == *"microsoft"* ]]; then
  # Windows or WSL fallback (pointing to the raw file in the repo)
  # Using relative path from home directory or an absolute Windows path
  npm config set cafile "$HOME/.dotfiles/files/certs/STRATEC-Chain.crt" --global
fi

# PNPM automatically reads ~/.npmrc and global npmrc, so it will inherit these settings!
echo "NPM/PNPM configured successfully!"
