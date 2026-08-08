#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0)]
    [string]$Target,

    [string]$Distro,
    [string]$Path,

    [switch]$All,
    [switch]$List,
    [switch]$DryRun,
    [switch]$Help,

    [string]$Method = 'Auto'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Show-Usage {
    @'
Offline WSL VHDX compactor.

This script does not boot any WSL distro. It finds the distro VHDX from the
registry, or accepts a direct .vhdx path, and compacts it offline.

Usage:
  .\shrink-wsl-vhdx.ps1 -List
  .\shrink-wsl-vhdx.ps1 -All
  .\shrink-wsl-vhdx.ps1 -Distro "Ubuntu-24.04"
  .\shrink-wsl-vhdx.ps1 -Path "C:\Users\you\AppData\Local\wsl\{GUID}\ext4.vhdx"
  .\shrink-wsl-vhdx.ps1 -Method DiskPart -DryRun

Method values:
  Auto, DiskPart, OptimizeVhd

Notes:
  - Run from an elevated PowerShell session for actual compaction.
  - Real savings depend on whether free space inside ext4 had been zeroed or trimmed.
  - The VHDX must not be in use.
'@ | Write-Output
}

function Write-Step {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "==> $Message" -ForegroundColor Green
}

function Format-Bytes {
    param([Parameter(Mandatory)][Int64]$Bytes)

    if ($Bytes -ge 1TB) { return '{0:N2} TiB' -f ($Bytes / 1TB) }
    if ($Bytes -ge 1GB) { return '{0:N2} GiB' -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return '{0:N2} MiB' -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return '{0:N2} KiB' -f ($Bytes / 1KB) }
    return '{0:N0} B' -f $Bytes
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-OptimizeVhdAvailable {
    return [bool](Get-Command Optimize-VHD -ErrorAction SilentlyContinue)
}

function Resolve-Method {
    param([Parameter(Mandatory)][string]$Name)

    switch ($Name.ToLowerInvariant()) {
        'auto' { return 'Auto' }
        'diskpart' { return 'DiskPart' }
        'optimizevhd' { return 'OptimizeVhd' }
        'optimize-vhd' { return 'OptimizeVhd' }
        default { throw "Unsupported method '$Name'. Use Auto, DiskPart, or OptimizeVhd." }
    }
}

function Get-WslRegistryTargets {
    $root = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss'
    $keys = Get-ChildItem -Path $root -ErrorAction SilentlyContinue | Where-Object {
        $_.PSChildName -match '^\{.+\}$'
    }

    foreach ($key in $keys) {
        $item = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
        if (-not $item.BasePath) {
            continue
        }

        $vhdx = Join-Path -Path $item.BasePath -ChildPath 'ext4.vhdx'
        if (-not (Test-Path -LiteralPath $vhdx)) {
            continue
        }

        [pscustomobject]@{
            Name = $item.DistributionName
            Vhdx = $vhdx
        }
    }
}

function Resolve-Targets {
    param(
        [string]$Target,
        [string]$Distro,
        [string]$Path,
        [switch]$All
    )

    $registryTargets = @(Get-WslRegistryTargets)

    if ($Path) {
        $resolved = Convert-Path -LiteralPath $Path -ErrorAction Stop
        return @([pscustomobject]@{
                Name = 'custom VHDX'
                Vhdx = $resolved
            })
    }

    if ($Distro) {
        $matches = @($registryTargets | Where-Object { $_.Name -ieq $Distro })
        if ($matches.Count -eq 0) {
            throw "No matching distro was found: $Distro"
        }
        return $matches
    }

    if ($All) {
        if ($registryTargets.Count -eq 0) {
            throw 'No WSL VHDX files were found in the registry.'
        }
        return $registryTargets
    }

    if ($Target) {
        if ($Target -match '\.vhdx$' -or (Test-Path -LiteralPath $Target -ErrorAction SilentlyContinue)) {
            $resolved = Convert-Path -LiteralPath $Target -ErrorAction Stop
            return @([pscustomobject]@{
                    Name = 'custom VHDX'
                    Vhdx = $resolved
                })
        }

        $matches = @($registryTargets | Where-Object { $_.Name -ieq $Target })
        if ($matches.Count -eq 0) {
            throw "No matching distro was found: $Target"
        }
        return $matches
    }

    if ($registryTargets.Count -eq 0) {
        throw 'No WSL VHDX files were found in the registry.'
    }

    return $registryTargets
}

function Invoke-DiskPartScript {
    param([Parameter(Mandatory)][string[]]$Lines)

    $tempFile = [System.IO.Path]::GetTempFileName()
    try {
        Set-Content -LiteralPath $tempFile -Value $Lines -Encoding Ascii
        $output = & diskpart.exe /s $tempFile 2>&1
        $text = ($output | ForEach-Object { "$_" }) -join [Environment]::NewLine
        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output   = $text
        }
    }
    finally {
        Remove-Item -LiteralPath $tempFile -ErrorAction SilentlyContinue
    }
}

function Invoke-DiskPartCompact {
    param([Parameter(Mandatory)][string]$Vhdx)

    $attempts = @(
        @(
            "select vdisk file=`"$Vhdx`"",
            'attach vdisk readonly',
            'compact vdisk',
            'detach vdisk',
            'exit'
        ),
        @(
            "select vdisk file=`"$Vhdx`"",
            'attach vdisk',
            'compact vdisk',
            'detach vdisk',
            'exit'
        )
    )

    $last = $null
    foreach ($lines in $attempts) {
        $last = Invoke-DiskPartScript -Lines $lines
        if ($last.ExitCode -eq 0 -and $last.Output -notmatch 'unable to process the parameters|Virtual Disk Service error|The parameter is incorrect') {
            return
        }
    }

    throw "DiskPart failed.`n$($last.Output)"
}

function Invoke-OptimizeVhdCompact {
    param([Parameter(Mandatory)][string]$Vhdx)

    Import-Module Hyper-V -ErrorAction SilentlyContinue | Out-Null
    Optimize-VHD -Path $Vhdx -Mode Full -ErrorAction Stop | Out-Null
}

function Invoke-Compaction {
    param(
        [Parameter(Mandatory)]$Item,
        [Parameter(Mandatory)][string]$MethodName
    )

    $before = (Get-Item -LiteralPath $Item.Vhdx -ErrorAction Stop).Length

    Write-Step $Item.Name
    Write-Host "  path:   $($Item.Vhdx)"
    Write-Host "  before: $(Format-Bytes -Bytes $before)"
    Write-Host "  method: $MethodName"

    if ($DryRun) {
        return
    }

    if (-not $PSCmdlet.ShouldProcess($Item.Vhdx, "Compact $($Item.Name)")) {
        return
    }

    switch ($MethodName) {
        'DiskPart' { Invoke-DiskPartCompact -Vhdx $Item.Vhdx }
        'OptimizeVhd' { Invoke-OptimizeVhdCompact -Vhdx $Item.Vhdx }
        default { throw "Unexpected method: $MethodName" }
    }

    $after = (Get-Item -LiteralPath $Item.Vhdx -ErrorAction Stop).Length
    $saved = $before - $after

    Write-Host "  after:  $(Format-Bytes -Bytes $after)"
    if ($saved -gt 0) {
        Write-Host "  saved:  $(Format-Bytes -Bytes $saved)"
    }
    else {
        Write-Host '  saved:  0 B (nothing reclaimable was found)'
    }
}

if ($Help) {
    Show-Usage
    return
}

if (($null -ne $Target -and $Target -ne '') -and $Distro) {
    throw 'Use either Target or -Distro, not both.'
}

if (($null -ne $Target -and $Target -ne '') -and $Path) {
    throw 'Use either Target or -Path, not both.'
}

if ($Distro -and $Path) {
    throw 'Use either -Distro or -Path, not both.'
}

$Method = Resolve-Method -Name $Method

if ($Method -eq 'Auto') {
    if (Test-OptimizeVhdAvailable) {
        $Method = 'OptimizeVhd'
    }
    else {
        $Method = 'DiskPart'
    }
}

if ($Method -eq 'OptimizeVhd' -and -not (Test-OptimizeVhdAvailable)) {
    throw 'Optimize-VHD is not available here. Use -Method DiskPart instead.'
}

$targets = @(Resolve-Targets -Target $Target -Distro $Distro -Path $Path -All:$All)

if ($List) {
    $targets |
        Select-Object @{ Name = 'Distro'; Expression = { $_.Name } }, @{ Name = 'VHDX'; Expression = { $_.Vhdx } } |
        Format-Table -AutoSize
    return
}

if (-not $DryRun -and -not $WhatIfPreference -and -not (Test-IsAdministrator)) {
    throw 'Run this script from an elevated PowerShell session for actual compaction.'
}

Write-Step "Using method: $Method"
if ($DryRun) {
    Write-Warning 'Dry-run mode: nothing will be changed.'
}

foreach ($item in $targets) {
    Invoke-Compaction -Item $item -MethodName $Method
}
