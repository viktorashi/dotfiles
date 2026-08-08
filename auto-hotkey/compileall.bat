@echo off
SET "COMPILER=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
SET "OUT_DIR=compiled-hotkeys"

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

:: Loop through every .ahk file in the current directory
for %%f in (*.ahk) do (
    echo Compiling: %%f...
    "%COMPILER%" /in "%%f" /out "%OUT_DIR%\%%~nf.exe" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe"
)

echo Done!
pause
