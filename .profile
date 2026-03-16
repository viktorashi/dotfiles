# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# =======================
#                        |
# Working with the $PATH |
#                        |
# ======================|
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

export PATH="/home/istan/.local/share/pipx/venvs:$PATH"
export PATH="/home/istan/.local/bin:$PATH"
export PATH="$PATH:/mnt/c/Users/istan/AppData/Local/Programs/Git/bin"
export PATH="$PATH:/mnt/c/Users/istan/scoop/shims"
export PATH="$PATH:/mnt/c/Users/istan/AppData/Local/Programs/Git/usr/bin"
export PATH="$PATH:/mnt/c/nvm4w/nodejs"
export PATH="$PATH:/snap/bin"
export PATH="$PATH:/mnt/c/Program Files/Integrity/ILMClient13/bin/"
export PATH="$PATH:/usr/local/go/bin"

. "$HOME/.cargo/env"
export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"
export EDITOR="nvim -u NORC"
export VISUAL="nvim -u NORC"
export PROMPT='${COLOR_USR}%n@%M ${COLOR_DIR}${PWD#"${PWD%/*/*}/"} ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}${NEWLINE}% '
export NVM_DIR="$HOME/.nvm"
export ACR_NAME="stratecai"
export SERVICE_PRINCIPAL_NAME="ca04454e-62bc-4787-a26e-62469f8b5187"
export MC_KEYMAP=/etc/mc/mc.vim.keymap
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export GPG_TTY=$(tty)

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
