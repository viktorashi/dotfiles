param(
    [Parameter(Mandatory = $true)]
    [string]$CertificatePath
)

$ErrorActionPreference = 'Stop'
$certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
    (Resolve-Path -LiteralPath $CertificatePath).Path
)
$storePath = "Cert:\CurrentUser\Root\$($certificate.Thumbprint)"
if (-not (Test-Path -LiteralPath $storePath)) {
    Import-Certificate -FilePath $CertificatePath -CertStoreLocation Cert:\CurrentUser\Root | Out-Null
}
Get-Item -LiteralPath $storePath | Select-Object Subject, Thumbprint, NotAfter
