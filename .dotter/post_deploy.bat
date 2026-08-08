@echo off
rem Windows twin of post_deploy.sh. Dotter prefers this file over the .sh on Windows and
rem renders IT, so the {{#each}} below is expanded here, not in the .sh.
rem
rem sh.exe is resolved by absolute path from git: bare `sh` is not on PATH on a stock box,
rem and bare `bash` is C:\Windows\System32\bash.exe -- the WSL launcher, which would run
rem this against WSL's $HOME and appear to succeed.
setlocal
for /f "delims=" %%G in ('where git') do (set "GITEXE=%%G" & goto :found)
:found
if not defined GITEXE (echo git not found on PATH & exit /b 1)
for %%D in ("%GITEXE%") do set "SH=%%~dpD..\bin\sh.exe"
if not exist "%SH%" (echo sh.exe not found next to git & exit /b 1)

{{#each dotter.packages}}{{#if this}}
for %%S in ("scripts\{{@key}}\*.sh") do (
	echo ==^> %%S
	"%SH%" "%%S" || exit /b 1
)
{{/if}}{{/each}}
