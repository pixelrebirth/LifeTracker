function Get-LifeTracker {
    [CmdletBinding()]
    param (
        [switch]$SumOnly
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    
    process {
        $Output = Find-LiteDBDocument -Collection "token_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
        if($SumOnly){
            $Sum = $Output | Measure-Object -Sum -Property WillpowerToken,ChronoToken,TaskToken
            $Output = [PSCustomObject]@{
                WillpowerToken = ($Sum | Where Property -eq WillpowerToken).sum
                ChronoToken = ($Sum | Where Property -eq ChronoToken).sum
                TaskToken = ($Sum | Where Property -eq TaskToken).sum
            }
        }
        $Output
    }
}

function Get-DynamicParam {
    Param ([array]$ParamName,[array]$ParamCode,[switch]$Validate)

    $Count = 0
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

    $ParamName | foreach {
        
        $Name = $_
        $Scriptblock = $ParamCode[$count]
        $ParameterName = $Name
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $AttributeCollection.Add($ParameterAttribute)

        if (!$Validate){
            $arrSet = . $Scriptblock
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            $AttributeCollection.Add($ValidateSetAttribute)
        }

        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        $count++
    }
    return $RuntimeParameterDictionary
}

function Get-TaskletConfig {
    Get-Content "$script:LifeTrackerModulePath/config.json" | ConvertFrom-Json
}

function Request-LifeTrackerConfig {
    param(
        $Path = $script:DatabaseLocation
    )
    Import-Module PSLiteDB | Out-Null
    Open-LiteDBConnection -Path $Path | Out-Null
    
    $Tasklets = Get-Tasklet
    $script:Values = ($Tasklets.value | sort -unique).tolower()
    $script:Tags = ($Tasklets.tags | sort -unique).tolower()
    
    Close-LiteDBConnection | Out-Null
}

function Add-LifeTrackerTransaction {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]$TaskToken,
        [parameter(Mandatory=$true)]$WillpowerToken,
        [parameter(Mandatory=$true)]$ChronoToken,
        $Path = $script:DatabaseLocation        
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection -Path $Path | Out-Null
    }
    
    process {
        $Data = [PSCustomObject]@{
            WillpowerToken    = [int]$WillpowerToken
            ChronoToken       = [int]$ChronoToken
            TaskToken         = [int]$TaskToken
        }
        $Data | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection "token_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
    }
}

function New-TaskletDatabase {
    param(
        $Path = $script:DatabaseLocation
    )
    Import-Module PSLiteDB | Out-Null
    
    $WarningPreference = 'SilentlyContinue'

    New-LiteDBDatabase -Path $Path | Out-Null
    Open-LiteDBConnection -Path $Path | Out-Null
    
    $Collections = @(
        "tasklet",
        "tasklet_archive",
        "rewardlet",
        "rewardlet_transaction",
        "journlet_transaction",
        "timelet",
        "timelet_transaction",
        "habitlet",
        "habitlet_transaction",
        "token_transaction"
    )

    foreach ($Item in $Collections){
        New-LiteDBCollection "$item" | Out-Null
    }

    Close-LiteDBConnection
    
    if (Test-Path $Path){
        return "$Path Exists"
    }
    else {
        return $false
    }
}