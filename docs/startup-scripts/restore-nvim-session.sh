#!/usr/bin/env bash
set -euo pipefail

if [[ "${1-}" == "--norc" ]]; then
  if [[ -f Session.vim ]]; then
    exec nvim -u NORC -S
  fi
  exec nvim -u NORC
fi

exec nvim "+lua require('persistence').load()"
