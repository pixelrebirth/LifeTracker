function Get-DynamicParam {
    Param ([array]$ParamName,[array]$ParamCode)

    $Count = 0
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

    $ParamName | foreach {
        
        $Name = $_
        $Scriptblock = $ParamCode[$count]
        $ParameterName = $Name
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $AttributeCollection.Add($ParameterAttribute)

        $arrSet = . $Scriptblock
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)

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
