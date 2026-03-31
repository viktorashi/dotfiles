#!/bin/bash

# Ensure the script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo."
  exit 1
fi

echo "Starting unified CA certificate environment setup..."

# 1. Create the universal /etc/profile.d script (For all POSIX shells)
echo "-> Creating /etc/profile.d/custom-certs.sh..."
cat <<'EOF' >/etc/profile.d/custom-certs.sh
export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
export SSL_CERT_DIR="/etc/ssl/certs"
export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"
EOF
# Ensure it has the correct permissions to be read by all users
chmod 644 /etc/profile.d/custom-certs.sh

# 2. Append to /etc/environment (For PAM/Login managers, STRICTLY no 'export' commands)
echo "-> Updating /etc/environment..."
# Use grep to prevent duplicating lines if the script is run multiple times
if ! grep -q "SSL_CERT_FILE" /etc/environment; then
  cat <<'EOF' >>/etc/environment
SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
SSL_CERT_DIR="/etc/ssl/certs"
REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
NODE_EXTRA_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"
EOF
else
  echo "   (Variables already exist in /etc/environment, skipping addition)"
fi

# 3. Add the Zsh bridge for WSL (Since WSL bypasses standard login profiles)
echo "-> Adding WSL bridge to /etc/zsh/zshrc..."
# Check if the /etc/zsh directory exists, create if not
mkdir -p /etc/zsh
touch /etc/zsh/zshrc

if ! grep -q "custom-certs.sh" /etc/zsh/zshrc; then
  cat <<'EOF' >>/etc/zsh/zshrc

# Bridge to force Zsh to read universal profiles in WSL
if [ -f /etc/profile.d/custom-certs.sh ]; then
    source /etc/profile.d/custom-certs.sh
fi
EOF
else
  echo "   (Zsh bridge already exists, skipping addition)"
fi

echo ""
echo "===================================================================="
echo " SYSTEM AND SHELL CONFIGURATION COMPLETE!"
echo " Please restart your terminal or run 'wsl --shutdown' from Windows."
echo "===================================================================="
echo ""
echo " >>> MANUAL SYSTEMD CONFIGURATION REQUIRED <<< "
echo " To ensure background daemons and services also use these "
echo " certificates, you must manually edit the systemd configuration."
echo ""
echo " 1. Open the systemd config file:"
echo "    sudo nvim /etc/systemd/system.conf"
echo ""
echo " 2. Find the [Manager] section, uncomment #DefaultEnvironment=, and add:"
echo "    DefaultEnvironment=\"SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt\" \"SSL_CERT_DIR=/etc/ssl/certs\" \"REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt\" \"NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt\""
echo ""
echo " 3. Save and exit nvim, then reload the daemon and restart:"
echo "    sudo systemctl daemon-reload"
echo "    sudo reboot"
echo "===================================================================="
