#!/usr/bin/env bash
set -euo pipefail

bash ~/docs/startup-scripts/git-settings.sh
if [ -f "$HOME/docs/conf.sh" ]; then
  # shellcheck disable=SC1091
  source "$HOME/docs/conf.sh"
fi

chmod +x "$HOME/docs/restore-nvim-session.sh" "$HOME/docs/restore-vim-session.sh"
mkdir -p "$HOME/.vim/pack/codex/start" "$HOME/.vim/plugin"

if [ -L "$HOME/.vim/pack/codex/start/vim-obsession" ]; then
  rm -f "$HOME/.vim/pack/codex/start/vim-obsession"
fi

if [ ! -d "$HOME/.vim/pack/codex/start/vim-obsession/.git" ]; then
  rm -rf "$HOME/.vim/pack/codex/start/vim-obsession"
  git clone --depth 1 https://github.com/tpope/vim-obsession.git "$HOME/.vim/pack/codex/start/vim-obsession"
fi

ln -sfn "$HOME/docs/startup-scripts/obsession-bootstrap.vim" "$HOME/.vim/plugin/obsession-bootstrap.vim"
