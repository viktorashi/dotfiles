# Kill any lingering or frozen disable script so Wake/Unlock wins
Get-CimInstance Win32_Process -Filter "CommandLine LIKE '%disable_bt.ps1%'" -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessId -ne $PID } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.IsGenericMethod })[0]

[Windows.Devices.Radios.Radio, Windows.System.Devices, ContentType = WindowsRuntime] | Out-Null
$op = [Windows.Devices.Radios.Radio]::GetRadiosAsync()
$m = $asTaskGeneric.MakeGenericMethod([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
$t = $m.Invoke($null, @($op))
$t.Wait(3000) | Out-Null

$bt = $t.Result | Where-Object { $_.Kind -eq 'Bluetooth' }
if ($bt) {
    $setOp = $bt.SetStateAsync([Windows.Devices.Radios.RadioState]::On)
    $mSet = $asTaskGeneric.MakeGenericMethod([Windows.Devices.Radios.RadioAccessStatus])
    $tSet = $mSet.Invoke($null, @($setOp))
    $tSet.Wait(3000) | Out-Null
    Write-Host "Bluetooth Radio turned On (Result: $($tSet.Result))"
} else {
    Write-Host "No Bluetooth radio found."
}
