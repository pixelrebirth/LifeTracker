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
    
    $script:Character = Get-Character
}