#!/bin/sh
set -eu

version=0.2.3
url="https://github.com/IcyHot09/opencode-copilot-fusion/releases/download/v${version}/opencode-copilot-fusion-${version}.tgz"
destination="$HOME/.config/opencode/plugins/opencode-copilot-fusion-${version}.tgz"
temporary="${destination}.tmp.$$"

mkdir -p "$(dirname "$destination")"
trap 'rm -f "$temporary"' EXIT HUP INT TERM
curl --fail --location --retry 3 --output "$temporary" "$url"
echo '24ab1a2aa7d8f5a2fd1a7e2ef1c547e5e82f585f2c5e5f1d82606044c1b65a79  '"$temporary" | sha256sum --check --status
mv "$temporary" "$destination"
