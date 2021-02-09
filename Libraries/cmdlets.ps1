function Add-Tasklet {
    [cmdletbinding()]
    Param (
        $Title,
        $Tags
    )
    DynamicParam {
        . $global:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
    }
    Begin{
        $Value = $PsBoundParameters['Value']
    }
    Process {
        $Tasklet = [Tasklet]::new($Title,$Value)
        if ($Tags){
            $Tasklet.tags = @($Tags.split(','))
        }
    }
    End {
        $Tasklet.AddToDb()
        Write-Output "Tasklet Saved"
    }
}

function New-TaskletDatabase {
    param(
        $Path = $global:DatabaseLocation
    )
    Import-Module PSLiteDB | Out-Null
    
    $WarningPreference = 'SilentlyContinue'

    New-LiteDBDatabase -Path $Path | Out-Null
    Open-LiteDBConnection -Path $Path | Out-Null
    New-LiteDBCollection "tasklets" | Out-Null
    New-LiteDBCollection "tasklets_archive" | Out-Null
    Close-LiteDBConnection
    
    if (Test-Path $Path){
        return "$Path Exists"
    }
    else {
        return $false
    }
}

function Get-Tasklet {
    [cmdletbinding()]
    param(
        $Tags
    )
    DynamicParam {
        . $global:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
    }

    begin {
        $Value = $PsBoundParameters['Value']

        Import-Module PSLiteDB | Out-Null
        $OutputArray = @()
        Open-LiteDBConnection $global:DatabaseLocation | Out-Null
    }
    process {
        $GetDocuments = Find-LiteDBDocument -Collection "tasklets"
        if ($Tags){
            $GetDocuments = $GetDocuments |  where Tags -Contain $Tags
        }
        if ($Value){
            $GetDocuments = $GetDocuments |  where Value -Contains $Value
        }
        
        foreach ($Document in $GetDocuments){
            $OutputArray += [tasklet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            $OutputArray | Sort Weight -Descending
        }
        else {
            "No Tasklets Found"
        }
    }
}

function Register-TaskletTouch {
    [cmdletbinding()]
    param(
        $Tags
    )
    DynamicParam {
        . $global:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
    }

    begin{
        $Value = $PsBoundParameters['Value']

        $AllTasklets = Get-Tasklet
        if ($Tags){
            $AllTasklets = $AllTasklets |  where Tags -Contain $Tag
        }
        if ($Value){
            $AllTasklets = $AllTasklets |  where Value -Contains $Value
        }
    }
    process {
        if ($AllTasklets){
            Write-Host -ForegroundColor Yellow "`nPlease enter weight 1-5 or press return`n------"
            foreach($Index in 0..$($AllTasklets.count-1)){
                do {
                    $Title = $AllTasklets[$Index].Title
                    [int]$Weight  = Read-Host $Title
                    if ($AllTasklets.count -gt 1){
                        $PerTaskletDecrease = $Weight / ($AllTasklets.count-1)
                    }
                    else {
                        $PerTaskletDecrease = 0
                    }
                }
                until (
                    $Weight -ge 0 -AND $Weight -le 5
                )
                
                $AllTasklets[$Index].weight += ($Weight + $PerTaskletDecrease)
                foreach($Index in 0..$($AllTasklets.count-1)){
                    $AllTasklets[$Index].weight -= $PerTaskletDecrease
                }
            }
        }
    }
    end {
        if ($AllTasklets){
            foreach ($Index in 0..$($AllTasklets.count-1)) {
                $AllTasklets[$Index].UpdateDb()
            }
            $AllTasklets
        }
        else {"No Tasklets Found"}
    }
}

function Update-Tasklet {
    param(
        $Title,
        $Tags,
        $Value
    )
}
function Complete-Tasklet {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline=$true)]$InputObject
    )

    begin{
        Open-LiteDBConnection $global:DatabaseLocation | Out-Null
    }
    process{
        $InputObject | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection "tasklets_archive" | Out-Null
        try{
            Remove-LiteDbDocument -Collection 'tasklets' -Id $($InputObject._id.guid)
            if (!(Find-LiteDbDocument -Collection 'tasklets' -Id $($InputObject._id.guid) -WarningAction 0)){
                Write-Output "Tasklet [$($InputObject.title)] Completed"
            }
            else {throw "Something Happened in Remove-LiteDbDocument"}
        }
        catch {
            throw "Error occurred uploading or deleting object from archive, error: $($error[0].exception.message)"
            Close-LiteDBConnection | Out-Null
        }
    }
    end{
        Close-LiteDBConnection | Out-Null
    }
}