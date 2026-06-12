#!/usr/bin/env bash
set -euo pipefail

bash ~/docs/startup-scripts/git-settings.sh
source ~/docs/conf.sh
mkdir -p "$HOME/.local/share/editor-packages" "$HOME/.local/share/nvim/site/pack/codex/start" "$HOME/.vim/pack/codex/start" "$HOME/.config/nvim/plugin" "$HOME/.vim/plugin"

if [ ! -d "$HOME/.local/share/editor-packages/vim-obsession/.git" ]; then
  rm -rf "$HOME/.local/share/editor-packages/vim-obsession"
  git clone --depth 1 https://github.com/tpope/vim-obsession.git "$HOME/.local/share/editor-packages/vim-obsession"
fi
ln -sfn "$HOME/.local/share/editor-packages/vim-obsession" "$HOME/.local/share/nvim/site/pack/codex/start/vim-obsession"
ln -sfn "$HOME/.local/share/editor-packages/vim-obsession" "$HOME/.vim/pack/codex/start/vim-obsession"
ln -sfn "$HOME/docs/startup-scripts/obsession-bootstrap.vim" "$HOME/.config/nvim/plugin/obsession-bootstrap.vim"
ln -sfn "$HOME/docs/startup-scripts/obsession-bootstrap.vim" "$HOME/.vim/plugin/obsession-bootstrap.vim"
