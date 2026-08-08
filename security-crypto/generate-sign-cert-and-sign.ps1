$cert = New-SelfSignedCertificate -Subject "CN=LocalCodeSigner" -Type CodeSigningCert -CertStoreLocation "Cert:\LocalMachine\My"
# Export the public key
Export-Certificate -Cert $cert -FilePath "$env:TEMP\LocalCodeSigner.cer"

# Import to Trusted Root Certification Authorities
Import-Certificate -FilePath "$env:TEMP\LocalCodeSigner.cer" -CertStoreLocation "Cert:\LocalMachine\Root"

# Import to Trusted Publishers
Import-Certificate -FilePath "$env:TEMP\LocalCodeSigner.cer" -CertStoreLocation "Cert:\LocalMachine\TrustedPublisher"

Set-AuthenticodeSignature -FilePath "Microsoft.PowerShell.Core\FileSystem::\\wsl.localhost\Ubuntu-24.04\home\istan\projects-repos\SHWARMA_soft\script_kiddies\push-all-remotes.ps1" -Certificate $cert
