#!/bin/bash

# Find a unique backup directory name incrementally
get_unique_backup_dir() {
  local base_dir="$HOME/backup"
  local counter=1
  local backup_dir="${base_dir}_${counter}"
  while [ -d "$backup_dir" ]; do
    counter=$((counter + 1))
    backup_dir="${base_dir}_${counter}"
  done
  echo "$backup_dir"
}

BACKUP_DIR=$(get_unique_backup_dir)

# Define the safe conf command wrapper
conf() {
  local git_dir="$HOME/.cfg/"
  local work_tree="$HOME"
  
  # If the command is checkout, switch, co, or sw, wrap it safely to auto-backup conflicts
  if [[ "$1" = "checkout" || "$1" = "switch" || "$1" = "co" || "$1" = "sw" ]]; then
    local tmp_err
    tmp_err=$(mktemp)
    
    git --git-dir="$git_dir" --work-tree="$work_tree" "$@" 2> "$tmp_err"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
      local err_content
      err_content=$(cat "$tmp_err")
      
      # Parse the conflicting files from git output (lines starting with a tab)
      local conflicting_files
      conflicting_files=$(echo "$err_content" | grep -E $'^\t' | sed $'s/^\t//')
      
      if [ -n "$conflicting_files" ]; then
        echo "⚠️  Conflicting files detected. Backing up to: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        
        while IFS= read -r file; do
          [ -z "$file" ] && continue
          local local_path="$work_tree/$file"
          if [ -e "$local_path" ]; then
            local dest_path="$BACKUP_DIR/$file"
            mkdir -p "$(dirname "$dest_path")"
            echo "📦 Moving $file -> $dest_path"
            mv "$local_path" "$dest_path"
          fi
        done <<< "$conflicting_files"
        
        rm -f "$tmp_err"
        
        # Retry checkout/switch
        echo "🔄 Retrying command: conf $@"
        git --git-dir="$git_dir" --work-tree="$work_tree" "$@"
        return $?
      else
        cat "$tmp_err" >&2
        rm -f "$tmp_err"
        return $exit_code
      fi
    else
      rm -f "$tmp_err"
      return 0
    fi
  else
    # Run the standard git command
    git --git-dir="$git_dir" --work-tree="$work_tree" "$@"
  fi
}

echo "Now cloning dă marfă"

rm -rf ~/.cfg

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg

echo ".cfg" >>~/.gitignore #avoiding recursive weirdness

# Astea sa poti sa folosesti `conf` si dupa
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias config='conf'

conf config --local status.showUntrackedFiles no #only account for the files you specifically mention

# Safe checkout of main branch, backing up any conflicting files dynamically
conf checkout main

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
