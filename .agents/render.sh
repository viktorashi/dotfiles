#!/bin/sh
set -eu

mkdir -p "$HOME/.config/opencode" "$HOME/.codex"
rm -f "$HOME/.config/opencode/AGENTS.md" "$HOME/.codex/AGENTS.md"

{
	cat "$HOME/.agents/AGENTS.md"
	if [ -s "$HOME/.agents/opencode.tail.md" ]; then
		printf '\n\n'
		cat "$HOME/.agents/opencode.tail.md"
	fi
} >"$HOME/.config/opencode/AGENTS.md"

{
	cat "$HOME/.agents/AGENTS.md"
	if [ -s "$HOME/.agents/codex.tail.md" ]; then
		printf '\n\n'
		cat "$HOME/.agents/codex.tail.md"
	fi
} >"$HOME/.codex/AGENTS.md"
