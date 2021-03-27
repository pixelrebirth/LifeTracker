function Get-LifeTracker {
    [CmdletBinding()]
    param (
        [switch]$Full
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
        if(!$Full){
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
        [parameter(Mandatory=$true)]$FunctionName,
            $TaskToken,
            $WillpowerToken,
            $ChronoToken,
            $DbPath = $script:DatabaseLocation        
        )
        
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection -Path $DbPath | Out-Null
        $Config = Get-LifeTrackerConfig

        if (!$TaskToken) {
            $TransactionRatio = $Config.TransactionRatio.$FunctionName.split(':')
        }
    }
    
    process {
        if (!$TaskToken) {
            $Data = [PSCustomObject]@{
                Cmdlet            = $FunctionName
                WillpowerToken    = $TransactionRatio[0]
                ChronoToken       = $TransactionRatio[1]
                TaskToken         = $TransactionRatio[2]
                Ticks             = (Get-Date).Ticks
            }
        }
        else {
            $Data = [PSCustomObject]@{
                Cmdlet            = $FunctionName
                WillpowerToken    = [int]$WillpowerToken
                ChronoToken       = [int]$ChronoToken
                TaskToken         = [int]$TaskToken
                Ticks             = (Get-Date).Ticks
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
        "countlet_transaction",
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

function Optimize-Database {}

function Reset-LifeTrackerTransactionCollection {
    [CmdletBinding()]
    param (
        [switch]$AcceptResponsibility,
        $DbPath = $script:DatabaseLocation
    )
    
    begin {
        if (!$AcceptResponsibility){
            Write-Output "This is a dangerous cmdlet, you must accept responsibility."
            # Automatic Backup
            Break
        }
    }
            
    process {
        Open-LiteDBConnection -Path $DbPath | Out-Null
        Remove-LiteDBCollection "token_transaction" -Confirm:$False
        New-LiteDBCollection "token_transaction"
        Close-LiteDBConnection
    }
    
    end {
        Write-Output "LifeTracker Level Zero Activated"
    }
}