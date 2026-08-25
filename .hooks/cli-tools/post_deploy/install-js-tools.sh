#!/bin/sh
set -eu

command -v mise >/dev/null 2>&1 || {
  echo "mise is unavailable; skipping configured global tools" >&2
  exit 0
}

# Global runtimes and npm CLIs are declared in files/mise/config.toml.
# @types/bun remains a local dev dependency because TypeScript language servers
# resolve declaration packages from the current project, not global npm installs.
mise install
