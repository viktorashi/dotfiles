#!/bin/sh
set -eu

base="$HOME/.agents/AGENTS.md"
start="<!-- agents-render:shared-start -->"
end="<!-- agents-render:shared-end -->"

render() {
	target=$1
	tmp=$(mktemp)
	body=$(mktemp)
	prefix=$(mktemp)

	if [ -f "$target" ]; then
		if grep -Fxq "$end" "$target"; then
			awk -v end="$end" 'found { print } $0 == end { found = 1 }' "$target" | sed '/./,$!d' >"$body"
		else
			lines=$(wc -l <"$base")
			sed -n "1,${lines}p" "$target" >"$prefix"
			if cmp -s "$base" "$prefix"; then
				tail -n +$((lines + 1)) "$target" | sed '/./,$!d' >"$body"
			else
				cp "$target" "$body"
			fi
		fi
	else
		: >"$body"
	fi

	{
		printf '%s\n' "$start"
		cat "$base"
		printf '%s\n' "$end"
		if [ -s "$body" ]; then
			printf '\n\n'
			cat "$body"
		fi
	} >"$tmp"
	if ! cmp -s "$tmp" "$target"; then
		mv "$tmp" "$target"
	fi
	rm -f "$tmp"
	rm -f "$body" "$prefix"
}

mkdir -p "$HOME/.config/opencode" "$HOME/.codex"
render "$HOME/.config/opencode/AGENTS.md"
render "$HOME/.codex/AGENTS.md"
