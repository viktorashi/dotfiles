#!/bin/bash
CONFIG_FILE="$HOME/.config/nvim/lua/plugins/mason.lua"

{
  echo 'return {'
  echo '  {'
  echo '    "williamboman/mason.nvim",'
  echo '    opts = {'
  echo -n '      ensure_installed = {'
  echo
  ls "$HOME/.local/share/nvim/mason/packages" | sort | sed 's/.*/        "&",/'
  echo '      },'
  echo '    },'
  echo '  },'
  echo '}'
} >"$CONFIG_FILE"

echo "✅ Mason config updated in $CONFIG_FILE"
