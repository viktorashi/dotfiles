# efectiv nu potii frate sa faci un kkt din interfata de windows sa vezi ce aplicatii ai la startup sa le inchizi

# Usage example: daca doar dai run dă list la toate entryurile
# .\manage-startup-apps.ps1 -Action update -ShortName "MyScript" -Path "C:\NewPath\app.exe" -Type Registry
# .\manage-startup-apps.ps1 -Action delete -ShortName "Claude" 

param(
    # Set Mandatory to false and provide a default
    [Parameter(Mandatory=$false)]
    [ValidateSet("list", "delete", "create", "update")]
    [string]$Action = "list",

    [string]$ShortName,
    [string]$Path,
    [ValidateSet("Registry", "Task")]
    [string]$Type = "Registry"
)

switch ($Action) {
    "list" {
        Write-Host "--- Registry (Run Keys) ---" -ForegroundColor Cyan
        Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Format-List
        
        Write-Host "`n--- Scheduled Tasks ---" -ForegroundColor Cyan
        Get-ScheduledTask | Where-Object {$_.State -ne 'Disabled'} | Select-Object TaskName, TaskPath | Format-Table -AutoSize
    }

    "create" {
        if (-not $ShortName -or -not $Path) { Write-Error "Need both ShortName and Path for creation."; return }
        if ($Type -eq "Registry") {
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $ShortName -Value $Path -PropertyType String
        } else {
            $action = New-ScheduledTaskAction -Execute $Path
            $trigger = New-ScheduledTaskTrigger -AtLogOn
            Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $ShortName
        }
    }

    "delete" {
        if (-not $ShortName) { Write-Error "ShortName required for deletion."; return }
        if ($Type -eq "Registry") {
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $ShortName
        } else {
            Unregister-ScheduledTask -TaskName $ShortName -Confirm:$false
        }
    }

    "update" {
        # Update is just a delete followed by a create
        $Action = "delete"; . $MyInvocation.MyCommand.Path @PSBoundParameters
        $Action = "create"; . $MyInvocation.MyCommand.Path @PSBoundParameters
    }
}

# ce incercasem inainte:
#
# # asa le vezi:
# Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location
#
# #waitt, NICI ASS NU LE VAD PE TOATEE unde naiba e whatsauppu?  si nici nu e adv lista asta, ca nu m-i se deshcide automat Teams da aici zice ca cica da
#
# #uite asta de sus merge mai bine
#
