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
