#!/usr/bin/env bash
set -euo pipefail

EDITOR_PACKAGES_DIR="${EDITOR_PACKAGES_DIR:-$HOME/.local/share/editor-packages}"
OBSESSION_BOOTSTRAP_DIR="$EDITOR_PACKAGES_DIR/obsession-bootstrap"
OBSESSION_PLUGIN_DIR="$EDITOR_PACKAGES_DIR/vim-obsession"
VIM_PACK_START="$HOME/.vim/pack/codex/start"
NVIM_PACK_START="$HOME/.local/share/nvim/site/pack/codex/start"
SHARED_BOOTSTRAP_FILE="$OBSESSION_BOOTSTRAP_DIR/plugin/obsession-bootstrap.vim"
GLOBAL_GITIGNORE_FILE="${GLOBAL_GITIGNORE_FILE:-$HOME/.config/git/ignore}"

conf() {
  git --git-dir="$HOME/.cfg" --work-tree="$HOME" "$@"
}

mkdir -p "$EDITOR_PACKAGES_DIR" "$VIM_PACK_START" "$NVIM_PACK_START"

if [ ! -d "$OBSESSION_PLUGIN_DIR/.git" ]; then
  rm -rf "$OBSESSION_PLUGIN_DIR"
  git clone --depth 1 https://github.com/tpope/vim-obsession.git "$OBSESSION_PLUGIN_DIR"
fi

if ! grep -qxF 'Session.vim' "$GLOBAL_GITIGNORE_FILE" 2>/dev/null; then
  printf 'Session.vim\n' >>"$GLOBAL_GITIGNORE_FILE"
fi

git config --global core.excludesfile "$GLOBAL_GITIGNORE_FILE"

mkdir -p "$(dirname "$SHARED_BOOTSTRAP_FILE")"
cat >"$SHARED_BOOTSTRAP_FILE" <<'VIMSCRIPT'
if exists('g:ai_os_obsession_loaded')
  finish
endif
let g:ai_os_obsession_loaded = 1

function! s:in_git_repo() abort
  return !empty(findfile('.git', '.;')) || !empty(finddir('.git', '.;'))
endfunction

function! s:start_obsession() abort
  if !s:in_git_repo()
    return
  endif

  silent! Obsession Session.vim
endfunction

augroup ai_os_obsession
  autocmd!
  autocmd VimEnter * call s:start_obsession()
augroup END
VIMSCRIPT

ln -sfn "$OBSESSION_BOOTSTRAP_DIR" "$VIM_PACK_START/obsession-bootstrap"
ln -sfn "$OBSESSION_BOOTSTRAP_DIR" "$NVIM_PACK_START/obsession-bootstrap"
ln -sfn "$OBSESSION_PLUGIN_DIR" "$VIM_PACK_START/vim-obsession"
ln -sfn "$OBSESSION_PLUGIN_DIR" "$NVIM_PACK_START/vim-obsession"

conf status >/dev/null 2>&1 || true
chmod +x "$HOME/docs/startup-scripts/install-init-stuff.sh"
