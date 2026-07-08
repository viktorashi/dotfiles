#!/bin/sh
set -eu

{
  cat "$HOME/.agents/AGENTS.md"
  printf '\n\n'
  cat "$HOME/.agents/opencode.tail.md"
} > "$HOME/.config/opencode/AGENTS.md"

{
  cat "$HOME/.agents/AGENTS.md"
  printf '\n\n'
  cat "$HOME/.agents/codex.tail.md"
} > "$HOME/.codex/AGENTS.md"
