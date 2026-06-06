#!/bin/bash

echo "Now cloning dă marfă"

rm -rf ~/.cfg

git clone --bare https://github.com/viktorashi/dotfiles "$HOME"/.cfg

echo ".cfg" >> ~/.gitignore #avoiding recursive weirdness

# Extract the git wrapper script before checkout so safe backup works
mkdir -p "$HOME/docs/cfg-bin"
git --git-dir="$HOME/.cfg" show HEAD:docs/cfg-bin/git > "$HOME/docs/cfg-bin/git"
chmod +x "$HOME/docs/cfg-bin/git"

# Load all aliases and functions directly from the cloned repo
tmp_shared=$(mktemp)
git --git-dir="$HOME/.cfg" show HEAD:docs/shared.sh > "$tmp_shared"
. "$tmp_shared"
rm -f "$tmp_shared"

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
