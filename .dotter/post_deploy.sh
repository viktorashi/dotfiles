#!/bin/sh
# Runs every scripts/<package>/*.sh for the packages this machine selected.
# The {{#each}} below is rendered by dotter before this file is executed, so the list is
# fixed at deploy time and a package that is not selected leaves no trace here at all.
#
# CWD is the repo root. Do NOT use $0-relative paths: only this file is copied into
# .dotter/cache/, so its siblings do not exist next to it at run time.
set -e

run_dir() {
	[ -d "$1" ] || return 0
	for s in "$1"/*.sh; do
		[ -f "$s" ] || continue
		echo "==> $s"
		sh "$s"
	done
}

{{#each dotter.packages}}{{#if this}}
run_dir "scripts/{{@key}}"
{{/if}}{{/each}}
