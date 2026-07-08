#!/bin/sh
set -eu

base="$HOME/.agents/AGENTS.md"

render() {
	target=$1
	tmp=$(mktemp)
	body=$(mktemp)
	prefix=$(mktemp)

	if [ -f "$target" ]; then
		lines=$(wc -l <"$base")
		sed -n "1,${lines}p" "$target" >"$prefix"
		if cmp -s "$base" "$prefix"; then
			tail -n +$((lines + 1)) "$target" | sed '/./,$!d' >"$body"
		else
			cp "$target" "$body"
		fi
	else
		: >"$body"
	fi

	{
		cat "$base"
		if [ -s "$body" ]; then
			printf '\n\n'
			cat "$body"
		fi
	} >"$tmp"
	mv "$tmp" "$target"
	rm -f "$body" "$prefix"
}

mkdir -p "$HOME/.config/opencode" "$HOME/.codex"
render "$HOME/.config/opencode/AGENTS.md"
render "$HOME/.codex/AGENTS.md"
