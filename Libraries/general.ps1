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

        if ($Validate){
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

function Get-LifeTrackerConfig {
    Get-Content "$script:LifeTrackerModulePath/config.json" | ConvertFrom-Json
}

function Add-LifeTrackerTransaction {
    [CmdletBinding()]
    param (
        $TaskToken,
        $WillpowerToken,
        $ChronoToken,
        $FunctionName,
        $Path = $script:DatabaseLocation        
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection -Path $Path | Out-Null
        $Config = Get-LifeTrackerConfig
        if ($FunctionName) {
            $TransactionValues = $Config.TransactionValues.$FunctionName.split(';')
        }
    }
    
    process {
        if ($FunctionName) {
            $Data = [PSCustomObject]@{
                Cmdlet            = $MyInvocation.MyCommand.Name
                WillpowerToken    = $TransactionValues[0]
                ChronoToken       = $TransactionValues[1]
                TaskToken         = $TransactionValues[2]
            }
        }
        else {
            $Data = [PSCustomObject]@{
                Cmdlet            = $MyInvocation.MyCommand.Name
                WillpowerToken    = [int]$WillpowerToken
                ChronoToken       = [int]$ChronoToken
                TaskToken         = [int]$TaskToken
            }
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