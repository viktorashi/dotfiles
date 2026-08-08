# windows10 (MSYS2)

# MSYS2 toolchain, ahead of anything Windows puts on PATH
for d in /ucrt64/bin /msys64/usr/bin /usr/local/bin /usr/bin /bin; do
  [ -d "$d" ] && PATH="$d:$PATH"
done
export PATH

# overrides shared.sh: no shell script runner, go through powershell
alias cbc='clear && cargo build && powershell.exe ./copy_binaries.ps1'
alias sourceaiflask='source /c/Users/istan/Envs/ai_flaskulet/Scripts/activate'
