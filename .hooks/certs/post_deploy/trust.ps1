param (
    [string]$CertsDir = "$env:USERPROFILE\.dotfiles\files\certs"
)

# Requires Admin privileges to write to LocalMachine Root store
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator to install certificates globally."
    break
}

Write-Host "Installing certificates from $CertsDir to Windows Trusted Root Store..."

$certs = Get-ChildItem -Path $CertsDir -Include *.crt -File -Recurse

if ($certs.Count -eq 0) {
    Write-Host "No .crt files found in $CertsDir. Skipping."
    return
}

foreach ($cert in $certs) {
    Write-Host "Importing $($cert.Name)..."
    Import-Certificate -FilePath $cert.FullName -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
}

Write-Host "Certificates installed successfully!"
