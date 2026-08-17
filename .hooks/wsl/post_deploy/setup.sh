powershell.exe "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"

powershell.exe "scoop install git"

git config --global credential.helper "/mnt/c/Users/istan/scoop/apps/git/2.55.0.3/mingw64/bin/git-credential-manager.exe"
git config --global credential.https://dev.azure.com.useHttpPath true

sudo chattr +i /etc/resolv.conf

# Disables root password (optional)
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
