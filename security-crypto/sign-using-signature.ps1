# Check for Administrator privileges and self-elevate if necessary
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating privileges to Administrator..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$cert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Subject -match "CN=LocalCodeSigner" } | Sort-Object NotBefore -Descending | Select-Object -First 1

if (-not $cert) {
    Write-Warning "Code signing certificate not found in LocalMachine store!"
    Pause
    exit
}

# The WSL file path
$wslPath = "\\wsl.localhost\Ubuntu-24.04\home\istan\projects-repos\SHWARMA_soft\script_kiddies\sign-using-signature.ps1"

Set-AuthenticodeSignature -FilePath $wslPath -Certificate $cert
