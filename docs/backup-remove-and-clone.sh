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
  "$HOME/docs/"
  "$HOME/.vimrc"
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

#acm iau tot ce m-i se cuvine gen

echo "Now cloning dă marfă"

config() {
  git --git-dir="$HOME/.cfg/" --work-tree="$HOME" "$@"
}

conf() {
  config "$@"
}

rm -rf ~/.cfg

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg

echo ".cfg" >>~/.gitignore #avoiding reccusrive weirdness

# astea sa poti sa folosesti `conf` si dupa
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias config='conf'

conf config --local status.showUntrackedFiles no #only account for the files you specifically mention
conf checkout main
conf config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
conf fetch
conf branch --set-upstream-to=origin/main
conf switch mac
conf branch --set-upstream-to=origin/mac
conf switch windows10
conf branch --set-upstream-to=origin/windows10
conf checkout main

cd ~/docs/ || exit
#no hackerino
chmod +x git-settings.sh
./git-settings.sh
