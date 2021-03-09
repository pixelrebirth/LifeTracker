$script:LifeTrackerModulePath = $PSScriptRoot
$script:DatabaseLocation = "\\PIXELROUTER\share\database\LifeTracker.db"

$AllFiles = Get-ChildItem -Path "$script:LifeTrackerModulePath/Libraries/*.ps1" -Recurse -Exclude *.tests.*,RunPester.ps1
$AllFiles | ForEach {. $Input}

Import-Module PSLiteDB