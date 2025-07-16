### toate-s in `config/scripts`

## Run it in `bash, zsh` etc or create a `script.sh` for each and run it in a GNU shell (even on windows)

Download all of them from [here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fviktorashi%2Fmy-config%2Ftree%2Fmain%2Fconfig_scripts)

### Back it up

```bash
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
```

### Cloning the actual config

```bash
echo "Now cloning dă marfă"

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg
echo ".cfg" >>.gitignore #avoiding reccusrive weirdness
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no #only account for the files you specifically mention
config checkout
```

##### Now if you did it right you should also have these in your `~/.zshrc and ~/.bashrc` config, allowing you to use it

```bash
config_worktree_folder="$HOME"
git_dir="${config_worktree_folder}/.cfg/"
alias configotofolder="cd ${config_worktree_folder}"
alias config="git --git-dir=${git_dir} --work-tree=${config_worktree_folder}"
alias configst="config status"
alias configadd="config add ${config_worktree_folder}/.config/nvim && config status"
alias conf="configadd"
alias configlazygit="lazygit --git-dir=${config_worktree_folder}/.cfg/ --work-tree=${config_worktree_folder}"
```

> [!IMPORTANT]
if on Windows you need to hard-link .config/nvim to %USERPROFILE%AppData\Local\nvim so Neovim sees it!

```PS1

#Requires -RunAsAdministrator

<#
.SYNOPSIS
    create junction to link Neovim config from  ~/.config to AppData/Local.

.DESCRIPTION

    from: %USERPROFILE%\AppData\Local\nvim
    to:   %USERPROFILE%\.config\nvim

    it includes checks to ensure the source directory exists and the target
    path is not already in use.

    IMPORTANT: needs admin
#>

# Strict mode helps catch common errors
Set-StrictMode -Version Latest

$sourceRelativePath = ".config\nvim"
$targetRelativePath = "AppData\Local\nvim"

try {
    $userProfile = $env:USERPROFILE
    if (-not $userProfile) {
        throw "Could not determine the user profile directory. Exiting."
    }

    # Construct the full absolute paths
    $sourcePath = Join-Path -Path $userProfile -ChildPath $sourceRelativePath
    $targetPath = Join-Path -Path $userProfile -ChildPath $targetRelativePath

    Write-Host "--------------------------------------------------"
    Write-Host "Neovim Config Linker"
    Write-Host "--------------------------------------------------"
    Write-Host "Source (points to): $sourcePath"
    Write-Host "Target (link created at): $targetPath"
    Write-Host ""

    Write-Host "Checking for source directory..." -NoNewline
    if (-not (Test-Path -Path $sourcePath -PathType Container)) {
        throw "The source directory does not exist at '$sourcePath'. Please create it first."
    }
    Write-Host " [OK]"

    Write-Host "Checking target path..." -NoNewline
    if (Test-Path -Path $targetPath) {
        $existingItem = Get-Item -Path $targetPath -Force
        if ($existingItem.LinkType -eq 'Junction' -or $existingItem.LinkType -eq 'SymbolicLink') {
            throw "A link already exists at the target location: '$targetPath'. No action needed."
        } else {
            throw "A file or directory already exists at '$targetPath'. Please remove or rename it before running this script."
        }
    }
    Write-Host " [OK]"

    Write-Host ""
    Write-Host "Attempting to create the directory junction..."
    Write-Host "You may be prompted for Administrator privileges."

    New-Item -Path $targetPath -ItemType Junction -Value $sourcePath | Out-Null

    if (Test-Path -Path $targetPath) {
        Write-Host ""
        Write-Host "✅ Success! The junction was created successfully."
        Write-Host "   '$targetPath' now points to '$sourcePath'."
    } else {
        throw "Failed to create the junction for an unknown reason."
    }

}
catch {
    Write-Host ""
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Script finished."

```
