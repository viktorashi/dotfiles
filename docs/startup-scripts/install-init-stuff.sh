#!/usr/bin/env bash
set -euo pipefail

bash ~/docs/startup-scripts/git-settings.sh
source ~/docs/conf.sh
mkdir -p "$HOME/.local/share/editor-packages" "$HOME/.local/share/nvim/site/pack/codex/start" "$HOME/.vim/pack/codex/start"

[ -d "$HOME/.local/share/editor-packages/vim-obsession/.git" ] || git clone --depth 1 https://github.com/tpope/vim-obsession.git "$HOME/.local/share/editor-packages/vim-obsession"
ln -sfn "$HOME/.local/share/editor-packages/vim-obsession" "$HOME/.local/share/nvim/site/pack/codex/start/vim-obsession"
ln -sfn "$HOME/.local/share/editor-packages/vim-obsession" "$HOME/.vim/pack/codex/start/vim-obsession"
