# efectiv nu potii frate sa faci un kkt din interfata de windows sa vezi ce aplicatii ai la startup sa le inchizi

# asa le vezi:
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location

#waitt, NICI ASS NU LE VAD PE TOATEE unde naiba e whatsauppu?  si nici nu e adv lista asta, ca nu m-i se deshcide automat Teams da aici zice ca cica da

#uite astea poate merg mai bine:

Write-Host "--- Registry Startup Items ---" -ForegroundColor Cyan
$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        # Removed redundant PSPath selection to fix the error
        Get-ItemProperty -Path $path | Format-List
    }
}

Write-Host "`n--- Scheduled Tasks (Enabled) ---" -ForegroundColor Cyan
# This is where 'hidden' apps like WhatsApp or Teams usually hide
Get-ScheduledTask | Where-Object {
    $_.State -ne 'Disabled' -and 
    $_.Triggers.Id -contains 'LogonTrigger' # Specifically look for log-on triggers
} | Select-Object TaskName, @{Name='Command'; Expression={$_.Actions.Execute}} | Format-Table -AutoSize

Write-Host "`n--- Startup Folder Items ---" -ForegroundColor Cyan
$userStartup = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"
if (Test-Path $userStartup) {
    Get-ChildItem $userStartup | Select-Object Name, FullName
}
