#!/usr/bin/env bash
set -euo pipefail

exec nvim "+lua require('persistence').load()"
