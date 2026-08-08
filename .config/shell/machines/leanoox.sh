# arch-wsl / leanoox — WSL2 under Windows, work laptop.

# Windows tools reachable from inside WSL
export PATH="$PATH:/mnt/c/Users/istan/AppData/Local/Programs/Git/bin"
export PATH="$PATH:/mnt/c/Users/istan/AppData/Local/Programs/Git/usr/bin"
export PATH="$PATH:/mnt/c/Users/istan/scoop/shims"
export PATH="$PATH:/mnt/c/Program Files/Integrity/ILMClient13/bin/"
[ -d /snap/bin ] && export PATH="$PATH:/snap/bin"

# midnight commander vim keymap, installed to /etc by the mc package
export MC_KEYMAP=/etc/mc/mc.vim.keymap

# work: azure container registry
export ACR_NAME="stratecai"
export SERVICE_PRINCIPAL_NAME="ca04454e-62bc-4787-a26e-62469f8b5187"

sshraspi() {
	/mnt/c/Users/istan/repos-projects/SHWARMA_soft/script_kiddies/ssh-raspi.sh
}
