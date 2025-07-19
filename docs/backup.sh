#!/bin/bash

# Backup directory name with the current date
BACKUP_DIR=~/backup_$(date +%Y-%m-%d)

# Create the backup directory
mkdir -p "$BACKUP_DIR"

echo "Backup process initiated. Files will be saved in: $BACKUP_DIR"

# Backup ~/.bashrc if it exists
if [ -f ~/.bashrc ]; then
  cp ~/.bashrc "$BACKUP_DIR"
  echo "✅ Successfully backed up .bashrc"
else
  echo "🔹 .bashrc not found, skipping."
fi

# Backup ~/.zshrc if it exists
if [ -f ~/.zshrc ]; then
  cp ~/.zshrc "$BACKUP_DIR"
  echo "✅ Successfully backed up .zshrc"
else
  echo "🔹 .zshrc not found, skipping."
fi

# Path to the Neovim configuration on Windows
WINDOWS_NVIM_CONFIG_PATH="$USERPROFILE/AppData/Local/nvim"
UNIX_NVIM_CONFIG_PATH="$HOME/.config/nvim/"

# Backup Neovim config if it exists
if [ -d "$WINDOWS_NVIM_CONFIG_PATH" ]; then
  cp -r "$WINDOWS_NVIM_CONFIG_PATH" "$BACKUP_DIR/nvim_config"
  echo "✅ Successfully backed up Neovim configuration"
else
  echo "🔹 Neovim configuration not found at $WINDOWS_NVIM_CONFIG_PATH, trying UNIX Path..."

  if [ -d "$UNIX_NVIM_CONFIG_PATH" ]; then
    cp -r "$UNIX_NVIM_CONFIG_PATH" "$BACKUP_DIR/nvim_config"
    echo "✅ Successfully backed up Neovim configuration"
  else
    echo "🔹 Neovim configuration not found at $UNIX_NVIM_CONFIG_PATH, skipping."
  fi

fi
echo "Backup process completed. "
