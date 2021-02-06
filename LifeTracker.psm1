$global:LifeTrackerModulePath = $PSScriptRoot
$AllFiles = Get-ChildItem -Path "$global:LifeTrackerModulePath/Libraries/*.ps1" -Recurse -Exclude *.tests.*,RunPester.ps1
$AllFiles | ForEach {. $Input}

New-TaskletDatabase