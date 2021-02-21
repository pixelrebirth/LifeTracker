$global:LifeTrackerModulePath = $PSScriptRoot
$global:DatabaseLocation = "\\PIXELROUTER\share\database\LifeTracker.db"

$AllFiles = Get-ChildItem -Path "$global:LifeTrackerModulePath/Libraries/*.ps1" -Recurse -Exclude *.tests.*,RunPester.ps1
$AllFiles | ForEach {. $Input}