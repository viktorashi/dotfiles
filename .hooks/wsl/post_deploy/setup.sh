#!/bin/sh
if [ ! -d "/mnt/c/Users/istan/scoop" ]; then
	powershell.exe -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression" </dev/null || true
	powershell.exe -NoProfile -Command "scoop install git" </dev/null || true
fi

git config --global credential.helper "/mnt/c/Users/istan/scoop/apps/git/2.55.0.3/mingw64/bin/git-credential-manager.exe"
git config --global credential.https://dev.azure.com.useHttpPath true

# Ensure systemd-resolved doesn't hijack WSL DNS
sudo systemctl disable systemd-resolved --now 2>/dev/null || true
if [ -L /etc/resolv.conf ]; then
	sudo rm -f /etc/resolv.conf
fi

# Disables root password (optional)
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER >/dev/null
