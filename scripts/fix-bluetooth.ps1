$ErrorActionPreference = 'Stop'

function Get-BluetoothAdapter {
    $dev = Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue |
        Where-Object { $_.FriendlyName -like '*Intel*Bluetooth*' -or ($_.InstanceId -like 'USB\*' -and $_.Class -eq 'Bluetooth') } |
        Select-Object -First 1

    if (-not $dev) {
        $dev = Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue |
            Where-Object { $_.InstanceId -notlike 'BTHENUM*' -and $_.InstanceId -notlike 'BTH\*' } |
            Select-Object -First 1
    }

    return $dev
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

$adapter = Get-BluetoothAdapter
$targetId = if ($adapter) { $adapter.InstanceId } else { '' }
$targetName = if ($adapter) { $adapter.FriendlyName } else { 'Intel(R) Wireless Bluetooth' }

if (-not $isAdmin) {
    Write-Host "Administrator privileges required to reset Bluetooth adapter ($targetName)." -ForegroundColor Yellow
    Write-Host "Requesting elevation via UAC..." -ForegroundColor Cyan

    $fixScriptBlock = @"
`$ErrorActionPreference = 'Continue'
Write-Host '=========================================' -ForegroundColor Cyan
Write-Host '     Resetting Windows Bluetooth Adapter ' -ForegroundColor Cyan
Write-Host '=========================================' -ForegroundColor Cyan

# 1. Close any older stuck fix-bluetooth or stopping powershell processes
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
    Where-Object { `$_.ProcessId -ne `$PID -and (`$_.CommandLine -like '*fix-bluetooth*' -or `$_.CommandLine -like '*bthserv*') } |
    ForEach-Object { Stop-Process -Id `$_.ProcessId -Force -ErrorAction SilentlyContinue }

# 2. If bthserv is hung in StopPending, terminate its svchost process
`$bthSvc = Get-CimInstance Win32_Service -Filter "Name='bthserv'" -ErrorAction SilentlyContinue
if (`$bthSvc -and (`$bthSvc.State -eq 'Stop Pending' -or `$bthSvc.State -eq 'Stopping')) {
    Write-Host "Terminating hung bthserv process `$(`$bthSvc.ProcessId)..." -ForegroundColor Yellow
    Stop-Process -Id `$bthSvc.ProcessId -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# 3. Locate adapter
`$adapter = Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue |
    Where-Object { (`$_.InstanceId -eq '$targetId') -or (`$_.FriendlyName -like '*Intel*Bluetooth*') -or (`$_.InstanceId -like 'USB\*' -and `$_.Class -eq 'Bluetooth') } |
    Select-Object -First 1

if (-not `$adapter) {
    `$adapter = Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue |
        Where-Object { `$_.InstanceId -notlike 'BTHENUM*' -and `$_.InstanceId -notlike 'BTH\*' } |
        Select-Object -First 1
}

if (-not `$adapter) {
    Write-Error 'Bluetooth adapter not found.'
    Start-Sleep -Seconds 2
    exit 1
}

Write-Host "Found adapter: `$(`$adapter.FriendlyName)" -ForegroundColor Gray
Write-Host "Instance ID:   `$(`$adapter.InstanceId)" -ForegroundColor Gray
Write-Host "Current Status:`$(`$adapter.Status)" -ForegroundColor Gray

# 4. Cycle hardware adapter state (DO NOT call Stop-Service bthserv as it hangs when driver is wedged)
Write-Host '`n[1/4] Disabling Bluetooth device...' -ForegroundColor Yellow
Disable-PnpDevice -InstanceId `$adapter.InstanceId -Confirm:`$false -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host '[2/4] Enabling Bluetooth device...' -ForegroundColor Yellow
Enable-PnpDevice -InstanceId `$adapter.InstanceId -Confirm:`$false -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

`$curStatus = (Get-PnpDevice -InstanceId `$adapter.InstanceId -ErrorAction SilentlyContinue).Status
`$curProblem = (Get-PnpDeviceProperty -InstanceId `$adapter.InstanceId -KeyName DEVPKEY_Device_ProblemCode -ErrorAction SilentlyContinue).Data

if (`$curStatus -ne 'OK' -or (`$curProblem -and `$curProblem -ne 0)) {
    Write-Host "Problem code `$curProblem persists. Triggering pnputil restart..." -ForegroundColor Yellow
    pnputil /restart-device "`$(`$adapter.InstanceId)" | Out-Null
    Start-Sleep -Seconds 2
    pnputil /scan-devices | Out-Null
    Start-Sleep -Seconds 2
}

# 5. Ensure Bluetooth Support Service is running
Write-Host '[3/4] Ensuring Bluetooth service is running...' -ForegroundColor Yellow
Set-Service -Name bthserv -StartupType Automatic -ErrorAction SilentlyContinue
Start-Process -FilePath 'net.exe' -ArgumentList 'start bthserv' -NoNewWindow -Wait -ErrorAction SilentlyContinue

# 6. Switch radio ON via Windows Runtime
Write-Host '[4/4] Ensuring Bluetooth radio is switched ON...' -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction SilentlyContinue
    `$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() |
        Where-Object { `$_.Name -eq 'AsTask' -and `$_.GetParameters().Count -eq 1 -and `$_.IsGenericMethod })[0]
    [Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType = WindowsRuntime] | Out-Null
    `$op = [Windows.Devices.Radios.Radio]::GetRadiosAsync()
    `$m = `$asTaskGeneric.MakeGenericMethod([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
    `$t = `$m.Invoke(`$null, @(`$op))
    if (`$t.Wait(3000)) {
        `$bt = `$t.Result | Where-Object { `$_.Kind -eq 'Bluetooth' }
        if (`$bt) {
            `$setOp = `$bt.SetStateAsync([Windows.Devices.Radios.RadioState]::On)
            `$mSet = `$asTaskGeneric.MakeGenericMethod([Windows.Devices.Radios.RadioAccessStatus])
            `$tSet = `$mSet.Invoke(`$null, @(`$setOp))
            `$tSet.Wait(3000) | Out-Null
            Write-Host 'Bluetooth radio state set to ON.' -ForegroundColor Green
        }
    }
} catch {
    Write-Warning "Could not set radio state: `$_"
}

# 7. Final status verification
`$finalDev = Get-PnpDevice -InstanceId `$adapter.InstanceId -ErrorAction SilentlyContinue
`$finalProblem = (Get-PnpDeviceProperty -InstanceId `$adapter.InstanceId -KeyName DEVPKEY_Device_ProblemCode -ErrorAction SilentlyContinue).Data

if (`$finalDev.Status -eq 'OK' -and (-not `$finalProblem -or `$finalProblem -eq 0)) {
    Write-Host '`nSUCCESS: Bluetooth adapter is OK and healthy!' -ForegroundColor Green
    Start-Sleep -Seconds 1
    exit 0
} else {
    Write-Error "Bluetooth adapter is still in status `$(`$finalDev.Status) (Problem: `$finalProblem)"
    Start-Sleep -Seconds 3
    exit 1
}
"@

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($fixScriptBlock)
    $encoded = [Convert]::ToBase64String($bytes)

    try {
        $proc = Start-Process powershell.exe -ArgumentList "-NoProfile -EncodedCommand $encoded" -Verb RunAs -Wait -PassThru
    }
    catch {
        Write-Error "Elevation canceled or failed: $_"
        exit 1
    }

    Start-Sleep -Seconds 1
    $adapter = Get-BluetoothAdapter
    if ($adapter) {
        $problem = (Get-PnpDeviceProperty -InstanceId $adapter.InstanceId -KeyName DEVPKEY_Device_ProblemCode -ErrorAction SilentlyContinue).Data
        if ($adapter.Status -eq 'OK' -and (-not $problem -or $problem -eq 0)) {
            Write-Host "Bluetooth adapter successfully fixed! ($($adapter.FriendlyName) - OK)" -ForegroundColor Green
            exit 0
        }
        else {
            Write-Error "Bluetooth adapter remains in status '$($adapter.Status)' (Problem code: $problem). Check Device Manager."
            exit 1
        }
    }
    else {
        Write-Error "Bluetooth adapter could not be verified after reset."
        exit 1
    }
}
else {
    # Already running as Administrator
    if (-not $adapter) {
        throw 'Bluetooth adapter not found. Check Device Manager.'
    }

    # If bthserv is stuck in StopPending, un-stick it
    $bthSvc = Get-CimInstance Win32_Service -Filter "Name='bthserv'" -ErrorAction SilentlyContinue
    if ($bthSvc -and ($bthSvc.State -eq 'Stop Pending' -or $bthSvc.State -eq 'Stopping')) {
        Write-Host "Terminating hung bthserv process $($bthSvc.ProcessId)..." -ForegroundColor Yellow
        Stop-Process -Id $bthSvc.ProcessId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    Write-Host "Resetting Bluetooth adapter $($adapter.FriendlyName)..." -ForegroundColor Cyan

    Write-Host "Disabling device $($adapter.InstanceId)..."
    Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    Write-Host "Enabling device $($adapter.InstanceId)..."
    Enable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    $curStatus = (Get-PnpDevice -InstanceId $adapter.InstanceId -ErrorAction SilentlyContinue).Status
    $curProblem = (Get-PnpDeviceProperty -InstanceId $adapter.InstanceId -KeyName DEVPKEY_Device_ProblemCode -ErrorAction SilentlyContinue).Data
    if ($curStatus -ne 'OK' -or ($curProblem -and $curProblem -ne 0)) {
        Write-Host "Running pnputil restart..." -ForegroundColor Yellow
        pnputil /restart-device "$($adapter.InstanceId)" | Out-Null
        Start-Sleep -Seconds 2
        pnputil /scan-devices | Out-Null
        Start-Sleep -Seconds 2
    }

    Set-Service -Name bthserv -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Process -FilePath 'net.exe' -ArgumentList 'start bthserv' -NoNewWindow -Wait -ErrorAction SilentlyContinue

    try {
        Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction SilentlyContinue
        $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() |
            Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.IsGenericMethod })[0]
        [Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType = WindowsRuntime] | Out-Null
        $op = [Windows.Devices.Radios.Radio]::GetRadiosAsync()
        $m = $asTaskGeneric.MakeGenericMethod([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
        $t = $m.Invoke($null, @($op))
        if ($t.Wait(3000)) {
            $bt = $t.Result | Where-Object { $_.Kind -eq 'Bluetooth' }
            if ($bt) {
                $setOp = $bt.SetStateAsync([Windows.Devices.Radios.RadioState]::On)
                $mSet = $asTaskGeneric.MakeGenericMethod([Windows.Devices.Radios.RadioAccessStatus])
                $tSet = $mSet.Invoke($null, @($setOp))
                $tSet.Wait(3000) | Out-Null
                Write-Host 'Bluetooth radio state set to ON.' -ForegroundColor Green
            }
        }
    } catch {
        Write-Warning "Could not toggle radio: $_"
    }

    $finalDev = Get-PnpDevice -InstanceId $adapter.InstanceId -ErrorAction SilentlyContinue
    $finalProblem = (Get-PnpDeviceProperty -InstanceId $adapter.InstanceId -KeyName DEVPKEY_Device_ProblemCode -ErrorAction SilentlyContinue).Data
    if ($finalDev.Status -eq 'OK' -and (-not $finalProblem -or $finalProblem -eq 0)) {
        Write-Host "SUCCESS: Bluetooth adapter is OK and ready!" -ForegroundColor Green
    } else {
        throw "Bluetooth adapter is still in status $($finalDev.Status) (Problem code: $finalProblem)"
    }
}
