$ErrorActionPreference = 'Stop'

$adapter = Get-PnpDevice -Class Bluetooth |
    Where-Object { $_.FriendlyName -like 'Intel(R) Wireless Bluetooth*' } |
    Select-Object -First 1

if (-not $adapter) {
    throw 'The Intel Bluetooth adapter was not found. Check Device Manager and the adapter driver.'
}

$problemCode = (Get-PnpDeviceProperty -InstanceId $adapter.InstanceId `
    -KeyName DEVPKEY_Device_ProblemCode -ErrorAction SilentlyContinue).Data

if ($problemCode -eq 22) {
    try {
        Enable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false -ErrorAction Stop
    }
    catch {
        if (-not ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
                [Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Error "Bluetooth is disabled and needs administrator rights. Run this in an elevated PowerShell (after handling any prompt yourself):`nEnable-PnpDevice -InstanceId '$($adapter.InstanceId)' -Confirm:`$false"
            exit 1
        }

        throw
    }
}
elseif ($problemCode -and $problemCode -ne 0) {
    throw "Bluetooth adapter reports problem code $problemCode. Check Device Manager."
}

$service = Get-Service -Name bthserv
if ($service.Status -ne 'Running') {
    try {
        Start-Service -Name bthserv
    }
    catch {
        Write-Error 'The Bluetooth Support Service could not be started. Start it from an elevated PowerShell after handling any prompt yourself.'
        exit 1
    }
}

$adapter = Get-PnpDevice -InstanceId $adapter.InstanceId
if ($adapter.Status -ne 'OK') {
    throw "Bluetooth adapter is still $($adapter.Status). Check Device Manager."
}

$headphones = Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue |
    Where-Object { $_.FriendlyName -like '*soundcore Q20i*' }

Write-Host 'Windows Bluetooth adapter is enabled.'
if ($headphones) {
    Write-Host 'Windows has Soundcore Q20i audio endpoints:'
    $headphones | ForEach-Object { Write-Host "  $($_.Status): $($_.FriendlyName)" }
}
else {
    Write-Host 'No Soundcore Q20i audio endpoints found yet. Pair the headset if needed.'
}

Write-Host 'Use the Bluetooth settings page to select/connect Soundcore Q20i.'
Start-Process 'ms-settings:bluetooth'
