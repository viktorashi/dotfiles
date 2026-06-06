#!/bin/bash

# Define the config command wrapper
config() {
  git --git-dir="$HOME/.cfg/" --work-tree="$HOME" "$@"
}

conf() {
  config "$@"
}

# Find a unique backup directory name incrementally
get_unique_backup_dir() {
  local base_dir="$HOME/backup_$(date +%Y-%m-%d)"
  local counter=1
  local backup_dir="${base_dir}_${counter}"
  while [ -d "$backup_dir" ]; do
    counter=$((counter + 1))
    backup_dir="${base_dir}_${counter}"
  done
  echo "$backup_dir"
}

BACKUP_DIR=$(get_unique_backup_dir)

# Helper function to check out a branch safely by backing up conflicting files
safe_checkout() {
  local branch="$1"
  local backup_dir="$2"
  
  echo "📥 Attempting checkout of $branch..."
  local checkout_output
  checkout_output=$(conf checkout "$branch" 2>&1)
  local exit_code=$?
  
  if [ $exit_code -ne 0 ]; then
    # Parse the conflicting files from git output
    local conflicting_files
    conflicting_files=$(echo "$checkout_output" | grep -E $'^\t' | sed $'s/^\t//')
    
    if [ -n "$conflicting_files" ]; then
      echo "⚠️  Conflicting files detected. Backing up to: $backup_dir"
      mkdir -p "$backup_dir"
      
      while IFS= read -r file; do
        [ -z "$file" ] && continue
        local local_path="$HOME/$file"
        if [ -e "$local_path" ]; then
          local dest_path="$backup_dir/$file"
          mkdir -p "$(dirname "$dest_path")"
          echo "📦 Moving $file -> $dest_path"
          mv "$local_path" "$dest_path"
        fi
      done <<< "$conflicting_files"
      
      # Retry checkout (WITHOUT --force)
      echo "🔄 Retrying checkout of $branch..."
      conf checkout "$branch"
    else
      echo "❌ Checkout of $branch failed with error:"
      echo "$checkout_output"
      return $exit_code
    fi
  else
    echo "✅ Checked out $branch successfully."
  fi
}

echo "📁 Unique backup folder set to: $BACKUP_DIR"
echo "Now cloning dă marfă"

rm -rf ~/.cfg

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg

echo ".cfg" >>~/.gitignore #avoiding recursive weirdness

# Astea sa poti sa folosesti `conf` si dupa
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias config='conf'

conf config --local status.showUntrackedFiles no #only account for the files you specifically mention

# Safe checkout of main branch, backing up any conflicting files dynamically
safe_checkout main "$BACKUP_DIR"

conf config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
conf fetch

# Set upstream tracking dynamically for all local branches without checking them out
for branch in $(conf branch --format='%(refname:short)'); do
  conf branch --set-upstream-to=origin/"$branch" "$branch" 2>/dev/null || true
done

#no hackerino
chmod +x ~/docs/git-settings.sh
~/docs/git-settings.sh

source ~/.bashrc
