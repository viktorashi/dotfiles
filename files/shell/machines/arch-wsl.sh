#! /usr/bin/bash
# arch-wsl / leanoox — WSL2 under Windows, work laptop.

# Windows tools reachable from inside WSL (appendWindowsPath is OFF in wsl.conf,
# so we whitelist only the handful of .exe's we actually call from Linux).
export PATH="$PATH:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0"
export PATH="$PATH:/mnt/c/WINDOWS"
export PATH="$PATH:/mnt/c/Users/istan/scoop/apps/vscode/current/bin"
export PATH="$PATH:/mnt/c/Program Files/Integrity/ILMClient13/bin/"

# midnight commander vim keymap, installed to /etc by the mc package
export MC_KEYMAP=/etc/mc/mc.vim.keymap

# work: azure container registry
export ACR_NAME="stratecai"
export SERVICE_PRINCIPAL_NAME="ca04454e-62bc-4787-a26e-62469f8b5187"

#cv de video
export GALLIUM_DRIVER=d3d12
export LIBVA_DRIVER_NAME=d3d12

alias pacman-install='sudo pacman -S --noconfirm'
alias pacmanS=pacman-install
alias pacS=pacman-install
alias yay-install='yay -S --noconfirm'
alias yayS=yay-install

#cica avoid, refreshing the lists without updating.
alias pacman-update='pacman-install -yu'
alias yay-update='yay-install -yu'

pkgof() {
	local bin_path
	bin_path="$(whence -p "$1")" || return 1
	pacman -Qo "$bin_path"
}

# ── SSH agent ────────────────────────────────────────────────────────
# wsl2-ssh-agent runs as a systemd user unit bridging Windows OpenSSH Agent
# (service is set to Automatic startup in Windows).
export SSH_AUTH_SOCK="$HOME/.ssh/wsl2-ssh-agent.sock"

# WSLg askpass — lets ssh-keygen (git SSH-signing) and ssh-add pop a
# graphical passphrase dialog when no controlling TTY is available
# (lazygit, IDE integrations, background scripts).
export SSH_ASKPASS="$HOME/.local/bin/ssh-askpass-wslg"

# With appendWindowsPath=false, scoop shims are no longer injected — nothing to strip.
export PATH

# MTU is handled by the wsl-mtu.service systemd unit — no need to run on every shell.
