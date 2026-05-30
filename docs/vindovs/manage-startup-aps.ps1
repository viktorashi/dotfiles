# efectiv nu potii frate sa faci un kkt din interfata de windows sa vezi ce aplicatii ai la startup sa le inchizi

# asa le vezi:
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location

#waitt, NICI ASS NU LE VAD PE TOATEE unde naiba e whatsauppu?  si nici nu e adv lista asta, ca nu m-i se deshcide automat Teams da aici zice ca cica da

#uite astea poate merg mai bine:
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("list", "delete", "create", "update")]
    [string]$Action = "list",

    [string]$ShortName,
    [string]$Path
)

$StoreFile = "startup_config.json"

# Load the "DB"
$config = if (Test-Path $StoreFile) { Get-Content $StoreFile | ConvertFrom-Json } else { @() }

switch ($Action) {
    "list" {
        $config | Format-Table
    }
    
    "create" {
        if (-not $ShortName -or -not $Path) { throw "Need ShortName and Path" }
        $new = [PSCustomObject]@{ ShortName = $ShortName; Path = $Path }
        $config += $new
        $config | ConvertTo-Json | Out-File $StoreFile
        # Logic to apply: Register-ScheduledTask or New-ItemProperty
    }
    
    "delete" {
        $config = $config | Where-Object { $_.ShortName -ne $ShortName }
        $config | ConvertTo-Json | Out-File $StoreFile
        # Logic to apply: Unregister-ScheduledTask or Remove-ItemProperty
    }
}
