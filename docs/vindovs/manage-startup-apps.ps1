# efectiv nu potii frate sa faci un kkt din interfata de windows sa vezi ce aplicatii ai la startup sa le inchizi

# Usage example: daca doar dai run dă list la toate entryurile
# .\manage-startup-apps.ps1 -Action update -ShortName "MyScript" -Path "C:\NewPath\app.exe" -Type Registry
# .\manage-startup-apps.ps1 -Action delete -ShortName "Claude" 
# Usage examples:
# 1. Listing items:
#    .\manage-startup-apps.ps1 -Action list                               # List all startup items (default)
#    .\manage-startup-apps.ps1 -Action list -ShortName "*"                # List all startup items
#    .\manage-startup-apps.ps1 -Action list -ShortName "Discord*"         # List items starting with "Discord"
#    .\manage-startup-apps.ps1 -Action list -ShortName "*Sync"            # List items ending with "Sync"
#    .\manage-startup-apps.ps1 -Action list -ShortName "App?"             # List items starting with "App" followed by 1 character (e.g. App1, AppA)
#    .\manage-startup-apps.ps1 -Action list -ShortName "[A-C]*"           # List items starting with A, B, or C
#    .\manage-startup-apps.ps1 -Action list -ShortName "[DT]*"            # List items starting with D or T
#
# 2. Deleting items:
#    .\manage-startup-apps.ps1 -Action delete -ShortName "Claude"          # Delete a specific item named "Claude"
#    .\manage-startup-apps.ps1 -Action delete -ShortName "Test*"          # Delete all items starting with "Test" (bulk delete, prompts for confirmation)
#    .\manage-startup-apps.ps1 -Action delete -ShortName "*"               # Delete all items (bulk delete, prompts for confirmation)
#
# 3. Creating/Updating:
#    .\manage-startup-apps.ps1 -Action create -ShortName "MyScript" -Path "C:\Path\app.exe" -Type Registry
#    .\manage-startup-apps.ps1 -Action update -ShortName "MyScript" -Path "C:\NewPath\app.exe" -Type Registry 

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
    param($Pattern)
    $results = @()
    
    # Check Registry
    $regPaths = @{
        "HKCU Run" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        "HKLM Run" = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
        "HKCU Wow6432 Run" = "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
        "HKLM Wow6432 Run" = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    }
    foreach ($source in $regPaths.Keys) {
        $path = $regPaths[$source]
        if (Test-Path $path) {
            $item = Get-Item -Path $path
            $matchedProps = $item.Property | Where-Object { $_ -like $Pattern }
            foreach ($p in $matchedProps) {
                $results += [PSCustomObject]@{ Source = $source; Name = $p }
            }
        }
    }

    # Check Startup Folders
    $folderPaths = @{
        "User Startup Folder" = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        "Common Startup Folder" = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    }
    foreach ($source in $folderPaths.Keys) {
        $path = $folderPaths[$source]
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -File -ErrorAction SilentlyContinue
            $matchedFiles = $files.Name | Where-Object { $_ -like $Pattern }
            foreach ($f in $matchedFiles) {
                $results += [PSCustomObject]@{ Source = $source; Name = $f }
            }
        }
    }

    # Check Tasks
    $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -like $Pattern }
    foreach ($t in $tasks) {
        $results += [PSCustomObject]@{ Source = "Scheduled Task"; Name = $t.TaskName }
    }
    return $results
}

switch ($Action) {
    "list" {
        $pattern = if ($ShortName) { $ShortName } else { "*" }
        
        Write-Host "=== Registry Run Keys ===" -ForegroundColor Cyan
        $regPaths = @{
            "HKCU Run" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
            "HKLM Run" = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
            "HKCU Wow6432 Run" = "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
            "HKLM Wow6432 Run" = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
        }
        $regItems = @()
        foreach ($source in $regPaths.Keys) {
            $path = $regPaths[$source]
            if (Test-Path $path) {
                $item = Get-Item -Path $path
                $matchedProps = $item.Property | Where-Object { $_ -like $pattern }
                if ($matchedProps) {
                    $propsObj = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
                    foreach ($p in $matchedProps) {
                        $regItems += [PSCustomObject]@{
                            Source = $source
                            Name = $p
                            Value = $propsObj.$p
                        }
                    }
                }
            }
        }
        if ($regItems) {
            $regItems | Format-Table -AutoSize
        } else {
            Write-Host "No matching registry items found." -ForegroundColor Gray
        }
        
        Write-Host "`n=== Startup Folders ===" -ForegroundColor Cyan
        $folderPaths = @{
            "User Startup Folder" = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
            "Common Startup Folder" = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
        }
        $folderItems = @()
        foreach ($source in $folderPaths.Keys) {
            $path = $folderPaths[$source]
            if (Test-Path $path) {
                $files = Get-ChildItem -Path $path -File -ErrorAction SilentlyContinue
                $matchedFiles = $files | Where-Object { $_.Name -like $pattern }
                foreach ($f in $matchedFiles) {
                    $targetPath = $f.FullName
                    if ($f.Extension -eq ".lnk") {
                        try {
                            $sh = New-Object -ComObject WScript.Shell
                            $targetPath = $sh.CreateShortcut($f.FullName).TargetPath
                        } catch {}
                    }
                    $folderItems += [PSCustomObject]@{
                        Source = $source
                        Name = $f.Name
                        TargetPath = $targetPath
                    }
                }
            }
        }
        if ($folderItems) {
            $folderItems | Format-Table -AutoSize
        } else {
            Write-Host "No matching startup folder items found." -ForegroundColor Gray
        }

        Write-Host "`n=== Scheduled Tasks ===" -ForegroundColor Cyan
        Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.State -ne 'Disabled' -and $_.TaskName -like $pattern } | Select-Object TaskName, TaskPath, State | Format-Table -AutoSize
    }

    "delete" {
        if (-not $ShortName) {
            Write-Host "FAILED: ShortName is required for delete action." -ForegroundColor Red
            return
        }
        $found = Get-StartupItem -Pattern $ShortName
        if ($found.Count -eq 0) { Write-Host "No startup item found matching '$ShortName'." -ForegroundColor Red; return }
        
        $hasWildcard = $ShortName.Contains('*') -or $ShortName.Contains('?')
        
        $targets = if ($hasWildcard) {
            Write-Host "Matching items found:" -ForegroundColor Cyan
            $found | Format-Table -AutoSize | Out-Host
            $confirm = Read-Host "Are you sure you want to delete these $($found.Count) items? (y/N)"
            if ($confirm -notmatch "^y(es)?$") {
                Write-Host "Deletion cancelled." -ForegroundColor Yellow
                return
            }
            $found
        } else {
            if ($found.Count -gt 1) {
                Write-Host "Collision detected! Found in multiple locations:"
                $found | Format-Table -AutoSize | Out-Host
                $choice = Read-Host "Select source to delete (exact Source name, partial match, or 'Both')"
                if ($choice -eq "Both") {
                    $found
                } else {
                    $found | Where-Object { $_.Source -like "*$choice*" }
                }
            } else { $found }
        }

        if (-not $targets) {
            Write-Host "No targets selected for deletion." -ForegroundColor Yellow
            return
        }

        foreach ($target in $targets) {
            try {
                if ($target.Source -like "*Run") {
                    $regPaths = @{
                        "HKCU Run" = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                        "HKLM Run" = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
                        "HKCU Wow6432 Run" = "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
                        "HKLM Wow6432 Run" = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
                    }
                    $path = $regPaths[$target.Source]
                    Remove-ItemProperty -Path $path -Name $target.Name -ErrorAction Stop
                }
                elseif ($target.Source -like "*Startup Folder") {
                    $folderPaths = @{
                        "User Startup Folder" = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
                        "Common Startup Folder" = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
                    }
                    $path = $folderPaths[$target.Source]
                    Remove-Item -Path (Join-Path $path $target.Name) -Force -ErrorAction Stop
                }
                elseif ($target.Source -eq "Scheduled Task") {
                    Unregister-ScheduledTask -TaskName $target.Name -Confirm:$false -ErrorAction Stop
                }
                Write-Host "SUCCESS: Deleted '$($target.Name)' from $($target.Source)." -ForegroundColor Green
            } catch {
                if ($_.Exception.Message -match "Access is denied" -or $_.FullyQualifiedErrorId -match "PermissionDenied") {
                    Write-Host "FAILED: Access Denied. You need to run PowerShell as Administrator to modify system-level items like '$($target.Name)' in $($target.Source)." -ForegroundColor Red
                } else {
                    Write-Host "FAILED: Could not delete '$($target.Name)' from $($target.Source). Error: $($_.Exception.Message)" -ForegroundColor Red
                }
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
