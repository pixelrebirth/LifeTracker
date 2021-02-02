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
    Get-Content ./config.json | ConvertFrom-Json
}

function Step-TaskletPriority {
    param($weight,$id)

    "$Id has weight increased by $weight"
    # param($numbers,$index,$weight)

    # $decrement = $weight / ($numbers.count-1)
    # ($numbers | measure-object -sum).sum
    
    # 0..($numbers.count-1) | foreach {$numbers[$_] -= $decrement}
    # $numbers[$index] += $decrement + $weight
    # $numbers | sort -Descending
    
    # ($numbers | measure-object -sum).sum
}