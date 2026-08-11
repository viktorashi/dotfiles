# arch-wsl / leanoox — WSL2 under Windows, work laptop.

# Windows tools reachable from inside WSL
export PATH="$PATH:/mnt/c/Program Files/Integrity/ILMClient13/bin/"

# midnight commander vim keymap, installed to /etc by the mc package
export MC_KEYMAP=/etc/mc/mc.vim.keymap

# work: azure container registry
export ACR_NAME="stratecai"
export SERVICE_PRINCIPAL_NAME="ca04454e-62bc-4787-a26e-62469f8b5187"

alias pacman-install='sudo pacman -S --noconfirm'
alias pacmanS=pacman-install
alias yay-install='yay -S --noconfirm'
alias yayS=yay-install
