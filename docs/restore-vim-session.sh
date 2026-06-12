#!/usr/bin/env bash
set -euo pipefail

if [[ -f Session.vim ]]; then
  exec vim -S
fi

exec vim
