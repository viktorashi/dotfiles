# All scripts are in `docs`

## Run it in `bash, zsh` etc or create a `script.sh` for each and run it in a GNU shell (even on windows)

Download all scripts from
[here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fviktorashi%2Fmy-config%2Ftree%2Fmain%2Fdocs)

You can also [get curl](https://curl.se/windows) if you don't have it
already to run these scripts directly. Or get it with
[Cygwin](https://www.cygwin.com)

#### Back up, clone and set up the repo

``` bash
curl -fsSL https://raw.githubusercontent.com/viktorashi/my-config/main/docs/backup-and-clone.sh | sh
```

orr you have do them sepperately ig:

### Back it up terry

just in case

`backup.sh`

    curl -fsSL https://raw.githubusercontent.com/viktorashi/my-config/main/docs/backup.sh | sh

### Cloning the actual config

`cloning-setup.sh`

    curl -fsSL https://raw.githubusercontent.com/viktorashi/my-config/main/docs/cloning-setup.sh | sh

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

No need to link `nvim-data` as well, because it'll get automatically
generated when first opening `nvim` with that config. If you're curious
about it anyways, Unix has it as `~/.local/share/nvim/`, and windows has
them at `C:\Users\istan\AppData\Local\nvim-data`

#### Contributing (u wont, dont lie)

To generate these docs I've used [pandoc](https://pandoc.org) with THIS
HIGHLY RECOMMENDED FILTER FOR `pandoc`:
[py-pandoc-include-code](https://github.com/veneres/py-pandoc-include-code)\
and you can simply run:

``` bash
make
```

if you're machine has [GNU Make](https://www.gnu.org/software/make)

else just do

``` bash
pandoc --filter=py-pandoc-include-code ~/docs/read-me.md -o ~/docs/README.md
```

before commiting orrr put it into that into the file go into
`~/.cfg/hooks/pre-commit` to make it a pre-commmit hook like ya boi
