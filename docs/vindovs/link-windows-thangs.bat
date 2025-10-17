@echo off
setlocal enabledelayedexpansion

REM ====================================================================
REM Script to create symbolic links/junctions from source to destination
REM Usage: Run as Administrator for best results
REM ====================================================================

echo Creating symbolic links and junctions...
echo.

REM Define your source and destination pairs below
REM Format: set "pair[N]=source_path|destination_path"
REM Use full paths or paths relative to this script

set "pair[0]=%USERPROFILE%\.config\nvim|%USERPROFILE%\AppData\Local\nvim"
set "pair[1]=%USERPROFILE%\docs\vindovs\windowsterm-settings.json|%USERPROFILE%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
set "pair[2]=%USERPROFILE%\docs\vindovs\msys-profile|C:\msys64\etc\profile"
set "pair[3]=%USERPROFILE%\docs\vindovs\nsswitch.conf|C:\msys64\etc\nsswitch.conf"

REM Count the number of pairs (update this if you add more pairs)
set pair_count=4

REM Process each pair
for /L %%i in (0,1,%pair_count%) do (
    if defined pair[%%i] (
        REM Split the pair by pipe delimiter
        for /f "tokens=1,2 delims=|" %%a in ("!pair[%%i]!") do (
            set "source=%%a"
            set "dest=%%b"
            
            echo Processing pair %%i:
            echo   Source: !source!
            echo   Destination: !dest!
            
            REM Check if source exists
            if exist "!source!\*" (
                REM Source is a directory
                if exist "!dest!" (
                    echo   WARNING: Destination already exists. Skipping...
                ) else (
                    mklink /J "!dest!" "!source!"
                    if !errorlevel! equ 0 (
                        echo   SUCCESS: Junction created
                    ) else (
                        echo   ERROR: Failed to create junction
                    )
                )
            ) else if exist "!source!" (
                REM Source is a file
                if exist "!dest!" (
                    echo   WARNING: Destination already exists. Skipping...
                ) else (
                    mklink "!dest!" "!source!"
                    if !errorlevel! equ 0 (
                        echo   SUCCESS: Symbolic link created
                    ) else (
                        echo   ERROR: Failed to create symbolic link
                    )
                )
            ) else (
                echo   ERROR: Source does not exist
            )
            echo.
        )
    )
)

echo.
echo Done!
pause
