# All scripts are in `docs`

## Run it in `bash, zsh` etc or create a `script.sh` for each and run it in a GNU shell (even on windows)

Download all scripts from
[here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fviktorashi%2Fmy-config%2Ftree%2Fmain%2Fdocs)

### Back it up terry

just in case

`backup.sh`

``` sh
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

`cloning-setup.sh`

``` sh
echo "Now cloning dă marfă"

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg
echo ".cfg" >>.gitignore #avoiding reccusrive weirdness
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

config config --local status.showUntrackedFiles no #only account for the files you specifically mention
config checkout
conf config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
conf branch --set-upstream-to=origin/main
conf switch mac
conf branch --set-upstream-to=origin/mac
conf switch windows10
conf branch --set-upstream-to=origin/windows10

cd docs/
#no hackerino
chmod +x git-settings.sh
./git-settings.sh
```

Now restart your `shell`. *Voila!*

##### You should have my lazy-aah aliases so you can use things like

``` bash
conf status
#or ,even more lazily:
conf s

#whenever you add a new file and want it to be tracked:
conf add <filename>

#even view it nicely if you have lazygit:
configlazygit
```

> \[!IMPORTANT\] If on Windows you need to hard-link .config/nvim to
> %USERPROFILE%AppData`\Local`{=tex}`\nvim `{=tex}and nvim-data as
> well!! so Neovim sees it!

Run these IN THE OG CMD, *not* PowerShell!!

`link-nvim.bat`

``` bat
@echo off
setlocal

:: ============================================================================
:: Neovim Config Linker (CMD Version)
::
:: This script creates a directory junction to link your Neovim configuration
:: from the .config directory to the AppData\Local directory.
::
::   - Target (Link): %USERPROFILE%\AppData\Local\nvim
::   - Source (Points to): %USERPROFILE%\.config\nvim
::
:: IMPORTANT: This script must be run as an Administrator.
:: To do this, right-click the .bat file and choose "Run as administrator".
:: ============================================================================

:: --- Configuration ---
set "SOURCE_RELATIVE_PATH=.config\nvim"
set "TARGET_RELATIVE_PATH=AppData\Local\nvim"

:: --- Script Body ---
echo --------------------------------------------------
echo Neovim Config Linker
echo --------------------------------------------------

:: Construct the full absolute paths
set "SOURCE_PATH=%USERPROFILE%\%SOURCE_RELATIVE_PATH%"
set "TARGET_PATH=%USERPROFILE%\%TARGET_RELATIVE_PATH%"

echo Source (points to): %SOURCE_PATH%
echo Target (link created at): %TARGET_PATH%
echo.

:: Check 1: Ensure the source directory exists.
echo Checking for source directory...
if not exist "%SOURCE_PATH%\" (
    echo [ERROR] The source directory does not exist at the path below.
    echo         Please create it first.
    echo         %SOURCE_PATH%
    goto :error
)
echo [OK] Source directory found.
echo.

:: Check 2: Ensure the target path is not already in use.
echo Checking target path...
if exist "%TARGET_PATH%" (
    echo [ERROR] A file, directory, or link already exists at the target location.
    echo         Please remove or rename it before running this script.
    echo         %TARGET_PATH%
    goto :error
)
echo [OK] Target path is available.
echo.

:: Attempt to create the junction.
echo Attempting to create the directory junction...
mklink /J "%TARGET_PATH%" "%SOURCE_PATH%"

:: Check if the mklink command was successful.
if errorlevel 1 (
    echo [ERROR] Failed to create the junction.
    echo         Please make sure you are running this script as an Administrator.
    goto :error
)

echo.
echo [SUCCESS] The junction was created successfully!
echo   '%TARGET_PATH%'
echo   now points to
echo   '%SOURCE_PATH%'
goto :end

:error
echo.
echo --------------------------------------------------
echo Script finished with errors.
echo --------------------------------------------------
exit /b 1

:end
echo.
echo --------------------------------------------------
echo Script finished successfully.
echo --------------------------------------------------
endlocal
pause

```

`link-nvim-data.bat`

``` bat
@echo off
setlocal

:: ============================================================================
:: Neovim Config Linker (CMD Version)
::
:: This script creates a directory junction to link your Neovim configuration
:: from the .config directory to the AppData\Local directory.
::
::   - Target (Link): %USERPROFILE%\AppData\Local\nvim-data
::   - Source (Points to): %USERPROFILE%\.local\share\nvim
::
:: IMPORTANT: This script must be run as an Administrator.
:: To do this, right-click the .bat file and choose "Run as administrator".
:: ============================================================================

:: --- Configuration ---
set "SOURCE_RELATIVE_PATH=.local\share\nvim"
set "TARGET_RELATIVE_PATH=AppData\Local\nvim-data"

:: --- Script Body ---
echo --------------------------------------------------
echo Neovim Config Linker
echo --------------------------------------------------

:: Construct the full absolute paths
set "SOURCE_PATH=%USERPROFILE%\%SOURCE_RELATIVE_PATH%"
set "TARGET_PATH=%USERPROFILE%\%TARGET_RELATIVE_PATH%"

echo Source (points to): %SOURCE_PATH%
echo Target (link created at): %TARGET_PATH%
echo.

:: Check 1: Ensure the source directory exists.
echo Checking for source directory...
if not exist "%SOURCE_PATH%\" (
    echo [ERROR] The source directory does not exist at the path below.
    echo         Please create it first.
    echo         %SOURCE_PATH%
    goto :error
)
echo [OK] Source directory found.
echo.

:: Check 2: Ensure the target path is not already in use.
echo Checking target path...
if exist "%TARGET_PATH%" (
    echo [ERROR] A file, directory, or link already exists at the target location.
    echo         Please remove or rename it before running this script.
    echo         %TARGET_PATH%
    goto :error
)
echo [OK] Target path is available.
echo.

:: Attempt to create the junction.
echo Attempting to create the directory junction...
mklink /J "%TARGET_PATH%" "%SOURCE_PATH%"

:: Check if the mklink command was successful.
if errorlevel 1 (
    echo [ERROR] Failed to create the junction.
    echo         Please make sure you are running this script as an Administrator.
    goto :error
)

echo.
echo [SUCCESS] The junction was created successfully!
echo   '%TARGET_PATH%'
echo   now points to
echo   '%SOURCE_PATH%'
goto :end

:error
echo.
echo --------------------------------------------------
echo Script finished with errors.
echo --------------------------------------------------
exit /b 1

:end
echo.
echo --------------------------------------------------
echo Script finished successfully.
echo --------------------------------------------------
endlocal
pause
```

to generate these docs I've installed THIS HIGHLY RECOMMENDED FILTER FOR
`pandoc`,
[py-pandoc-include-code](https://github.com/veneres/py-pandoc-include-code)\
and you can simply run:

``` bash
pandoc --filter=py-pandoc-include-code ~/docs/read-me.md -o ~/docs/README.md
```

before commiting orrr put it into that into the file go into
`~/.cfg/hooks/pre-commit` to make it a pre-commmit hook like ya boi
