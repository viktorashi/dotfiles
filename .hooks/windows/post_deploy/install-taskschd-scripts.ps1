# Requires Admin privileges to register scheduled tasks with system event queries
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Running as Administrator is required to configure Scheduled Tasks."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Determine dotfiles root directory and source scripts
$dotfilesRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -Parent)
$sourceDir = Join-Path $dotfilesRoot "files\windows\sleepy-eepy"
$targetDir = "C:\Scripts"

if (-not (Test-Path $sourceDir)) {
    # Fallback to standard location
    $sourceDir = "$env:USERPROFILE\.dotfiles\files\windows\sleepy-eepy"
}

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "Deploying Bluetooth sleep/wake scripts to $targetDir..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $sourceDir "disable_bt.ps1") -Destination (Join-Path $targetDir "disable_bt.ps1") -Force
Copy-Item -Path (Join-Path $sourceDir "enable_bt.ps1") -Destination (Join-Path $targetDir "enable_bt.ps1") -Force

# --- Task 1: DisableBT_OnSleep ---
Write-Host "Configuring Scheduled Task: DisableBT_OnSleep..." -ForegroundColor Cyan
$actionSleep = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Scripts\disable_bt.ps1"'
$triggerSleep = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler | New-CimInstance -ClientOnly
# Event 506 = Entering Modern Standby (S0), Event 42 = Entering Sleep (S3)
$triggerSleep.Subscription = '<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name="Microsoft-Windows-Kernel-Power"] and (EventID=506 or EventID=42)]]</Select></Query></QueryList>'
$triggerSleep.Enabled = $true

$settingsSleep = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances Parallel -Compatibility Win8
Register-ScheduledTask -TaskName 'DisableBT_OnSleep' -Action $actionSleep -Trigger $triggerSleep -Settings $settingsSleep -Force | Out-Null
Write-Host "SUCCESS: DisableBT_OnSleep registered." -ForegroundColor Green

# --- Task 2: EnableBT_OnWake ---
Write-Host "Configuring Scheduled Task: EnableBT_OnWake..." -ForegroundColor Cyan
$actionWake = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Scripts\enable_bt.ps1"'
$triggerWake = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler | New-CimInstance -ClientOnly
# Event 507 = Exiting Modern Standby, Event 107 = System Resume, Event 1 = Power-Troubleshooter Resume
$triggerWake.Subscription = '<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name="Microsoft-Windows-Kernel-Power"] and (EventID=507 or EventID=107)]]</Select></Query><Query Id="1" Path="System"><Select Path="System">*[System[Provider[@Name="Microsoft-Windows-Power-Troubleshooter"] and EventID=1]]</Select></Query></QueryList>'
$triggerWake.Enabled = $true

$settingsWake = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances Parallel -Compatibility Win8
Register-ScheduledTask -TaskName 'EnableBT_OnWake' -Action $actionWake -Trigger $triggerWake -Settings $settingsWake -Force | Out-Null
Write-Host "SUCCESS: EnableBT_OnWake registered." -ForegroundColor Green

Write-Host "`nAll sleep/wake Bluetooth tasks installed and ready!" -ForegroundColor Green
