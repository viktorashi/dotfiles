#!/bin/bash

BACKUP_DIR=~/backup_$(date +%Y-%m-%d)

mkdir -p "$BACKUP_DIR"
echo "📁 Backup process initiated. Files will be saved in: $BACKUP_DIR"
echo

CONFIG_PATHS=(
  "$HOME/.bashrc"
  "$HOME/.zshrc"
  "$HOME/.config/nvim"
  "$USERPROFILE/AppData/Local/nvim"
)

for CONFIG in "${CONFIG_PATHS[@]}"; do
  EXPANDED_PATH=$(eval echo "$CONFIG")

  if [ -f "$EXPANDED_PATH" ]; then
    cp "$EXPANDED_PATH" "$BACKUP_DIR"
    echo "✅ Backed up file: $CONFIG"
    
    rm "$EXPANDED_PATH" && echo "🗑️  Removed file: $CONFIG" || echo "❌ Failed to remove file: $CONFIG"

  elif [ -d "$EXPANDED_PATH" ]; then
    DEST_NAME=$(basename "$EXPANDED_PATH")
    cp -r "$EXPANDED_PATH" "$BACKUP_DIR/$DEST_NAME"
    echo "✅ Backed up directory: $CONFIG"
    
    rm -rf "$EXPANDED_PATH" && echo "🗑️  Removed directory: $CONFIG" || echo "❌ Failed to remove directory: $CONFIG"

  else
    echo "🔹 Not found or not a file/directory: $CONFIG — skipping."
  fi
done

echo
echo "✅ Backup and removal process completed."
