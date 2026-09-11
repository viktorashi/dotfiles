#!/bin/sh
set -eu

if command -v pacman >/dev/null 2>&1 && command -v mise >/dev/null 2>&1; then
	dotfiles_root=${DOTFILES:-"$HOME/.dotfiles"}
	"$dotfiles_root/files/bin/mise-sync-pacman" --auto
fi
