$script:LifeTrackerModulePath = $PSScriptRoot
$config = Get-Content $script:LifeTrackerModulePath/config.json | ConvertFrom-Json
$script:DatabaseLocation = $Config.DatabaseLocation
$script:DatabaseBackupLocation = $Config.DatabaseBackupLocation

$AllFiles = Get-ChildItem -Path "$script:LifeTrackerModulePath/Libraries/*.ps1" -Recurse -Exclude *.tests.*,RunPester.ps1
$AllFiles | ForEach {. $Input}

Backup-LifeTrackerDatabase
Import-Module PSLiteDB