#!/usr/bin/env bash
set -euo pipefail

session_dir="${PWD}"

if [[ -n "${TMUX_PANE-}" ]]; then
  tmux_dir="$(tmux display-message -p -t "$TMUX_PANE" "#{pane_current_path}" 2>/dev/null || true)"
  if [[ -n "$tmux_dir" ]]; then
    session_dir="$tmux_dir"
  fi
fi

session_file="${session_dir}/Session.vim"

if [[ -f "$session_file" ]]; then
  exec vim -c "source $session_file"
fi

exec vim
