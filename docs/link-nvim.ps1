#Requires -RunAsAdministrator

<#
.SYNOPSIS
    create junction to link Neovim config from  ~/.config to AppData/Local.

.DESCRIPTION

    from: %USERPROFILE%\AppData\Local\nvim
    to:   %USERPROFILE%\.config\nvim

    it includes checks to ensure the source directory exists and the target
    path is not already in use.

    IMPORTANT: needs admin
#>

# Strict mode helps catch common errors
Set-StrictMode -Version Latest

$sourceRelativePath = ".config\nvim"
$targetRelativePath = "AppData\Local\nvim"

try {
    $userProfile = $env:USERPROFILE
    if (-not $userProfile) {
        throw "Could not determine the user profile directory. Exiting."
    }

    # Construct the full absolute paths
    $sourcePath = Join-Path -Path $userProfile -ChildPath $sourceRelativePath
    $targetPath = Join-Path -Path $userProfile -ChildPath $targetRelativePath

    Write-Host "--------------------------------------------------"
    Write-Host "Neovim Config Linker"
    Write-Host "--------------------------------------------------"
    Write-Host "Source (points to): $sourcePath"
    Write-Host "Target (link created at): $targetPath"
    Write-Host ""

    Write-Host "Checking for source directory..." -NoNewline
    if (-not (Test-Path -Path $sourcePath -PathType Container)) {
        throw "The source directory does not exist at '$sourcePath'. Please create it first."
    }
    Write-Host " [OK]"

    Write-Host "Checking target path..." -NoNewline
    if (Test-Path -Path $targetPath) {
        $existingItem = Get-Item -Path $targetPath -Force
        if ($existingItem.LinkType -eq 'Junction' -or $existingItem.LinkType -eq 'SymbolicLink') {
            throw "A link already exists at the target location: '$targetPath'. No action needed."
        } else {
            throw "A file or directory already exists at '$targetPath'. Please remove or rename it before running this script."
        }
    }
    Write-Host " [OK]"

    Write-Host ""
    Write-Host "Attempting to create the directory junction..."
    Write-Host "You may be prompted for Administrator privileges."

    New-Item -Path $targetPath -ItemType Junction -Value $sourcePath | Out-Null

    if (Test-Path -Path $targetPath) {
        Write-Host ""
        Write-Host "✅ Success! The junction was created successfully."
        Write-Host "   '$targetPath' now points to '$sourcePath'."
    } else {
        throw "Failed to create the junction for an unknown reason."
    }

}
catch {
    Write-Host ""
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Script finished."

