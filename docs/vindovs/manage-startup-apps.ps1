# efectiv nu potii frate sa faci un kkt din interfata de windows sa vezi ce aplicatii ai la startup sa le inchizi

# Usage example: daca doar dai run dă list la toate entryurile
# .\manage-startup-apps.ps1 -Action update -ShortName "MyScript" -Path "C:\NewPath\app.exe" -Type Registry
# .\manage-startup-apps.ps1 -Action delete -ShortName "Claude" 

param(
    [Parameter(Position=0)]
    [ValidateSet("list", "delete", "create", "update")]
    [string]$Action = "list",

    [string]$ShortName,
    [string]$Path,
    [ValidateSet("Registry", "Task")]
    [string]$Type
)

function Get-StartupItem {
    param($Name)
    $results = @()
    # Check Registry (Note: This checks if the property EXISTS, not the path)
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    if (Test-Path $regPath) {
        $props = Get-ItemProperty -Path $regPath
        if ($props.PSObject.Properties[$Name]) {
            $results += [PSCustomObject]@{ Source = "Registry"; Name = $Name }
        }
    }
    # Check Tasks
    $task = Get-ScheduledTask | Where-Object { $_.TaskName -eq $Name }
    if ($task) {
        $results += [PSCustomObject]@{ Source = "Task"; Name = $Name }
    }
    return $results
}

switch ($Action) {
    "list" {
        Write-Host "--- Registry (Run Keys) ---" -ForegroundColor Cyan
        Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Format-List
        
        Write-Host "`n--- Scheduled Tasks ---" -ForegroundColor Cyan
        Get-ScheduledTask | Where-Object {$_.State -ne 'Disabled'} | Select-Object TaskName, TaskPath | Format-Table -AutoSize
    }

    "delete" {
        $found = Get-StartupItem -Name $ShortName
        if ($found.Count -eq 0) { Write-Host "No startup item found named '$ShortName'." -ForegroundColor Red; return }
        
        $target = if ($found.Count -gt 1) {
            Write-Host "Collision detected! Found in multiple locations:"
            $found | Format-Table
            $choice = Read-Host "Select source to delete (Registry/Task)"
            $found | Where-Object { $_.Source -eq $choice }
        } else { $found[0] }

        try {
            if ($target.Source -eq "Registry") {
                Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $target.Name -ErrorAction Stop
            } else {
                Unregister-ScheduledTask -TaskName $target.Name -Confirm:$false -ErrorAction Stop
            }
            Write-Host "SUCCESS: Deleted '$($target.Name)' from $($target.Source)." -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -match "Access is denied" -or $_.FullyQualifiedErrorId -match "PermissionDenied") {
                Write-Host "FAILED: Access Denied. You need to run PowerShell as Administrator to modify system-level tasks like '$($target.Name)'." -ForegroundColor Red
            } else {
                Write-Host "FAILED: Could not delete '$($target.Name)'. Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    "create" {
        if (-not $ShortName -or -not $Path) { Write-Error "Name and Path required."; return }
        $targetType = if ($Type) { $Type } else { "Task" }
        
        try {
            if ($targetType -eq "Registry") {
                New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $ShortName -Value $Path -PropertyType String -ErrorAction Stop
            } else {
                $action = New-ScheduledTaskAction -Execute $Path
                $trigger = New-ScheduledTaskTrigger -AtLogOn
                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $ShortName -ErrorAction Stop | Out-Null
            }
            Write-Host "SUCCESS: Created '$ShortName' as a $targetType." -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -match "Access is denied" -or $_.FullyQualifiedErrorId -match "PermissionDenied") {
                Write-Host "FAILED: Access Denied. You need to run PowerShell as Administrator to create this $targetType." -ForegroundColor Red
            } else {
                Write-Host "FAILED: Could not create '$ShortName'. Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    "update" {
        # Update is just a delete followed by a create using the script itself
        $Action = "delete"; . $MyInvocation.MyCommand.Path @PSBoundParameters
        $Action = "create"; . $MyInvocation.MyCommand.Path @PSBoundParameters
    }
}


# # asa le vezi:
# Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location
#
# #waitt, NICI ASS NU LE VAD PE TOATEE unde naiba e whatsauppu?  si nici nu e adv lista asta, ca nu m-i se deshcide automat Teams da aici zice ca cica da
#
# #uite asta de sus merge mai bine
#
