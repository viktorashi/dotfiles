#!/bin/sh
# vim-obsession is a plugin, not a config file, so it is cloned rather than linked.
# Idempotent: re-running only fast-forwards nothing and re-points the symlink.
set -e
dest="$HOME/.vim/pack/codex/start/vim-obsession"
mkdir -p "$HOME/.vim/pack/codex/start" "$HOME/.vim/plugin"
if [ ! -d "$dest/.git" ]; then
	rm -rf "$dest"
	git clone --depth 1 https://github.com/tpope/vim-obsession.git "$dest"
fi
ln -sfn "$HOME/.config/nvim/obsession-bootstrap.vim" "$HOME/.vim/plugin/obsession-bootstrap.vim"
