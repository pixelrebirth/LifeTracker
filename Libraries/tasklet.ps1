function New-Tasklet {
    [cmdletbinding()]
    Param (
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)]$Tags,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)]$Complexity
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {(Get-LifeTrackerConfig).values}
        return  Get-DynamicParam -Validate -ParamName Value -ParamCode  $ConfigValues
    }
    Begin{
        $Value = $PsBoundParameters['Value']
        if (!$Value){
            throw "Missing Value, Supply Value"
        }
        $Tags = @($Tags.split(','))
    }
    Process {
        $Tasklet = [Tasklet]::new($Title,$Tags,$Complexity)
        if ($Value){
            $Tasklet.Value = $Value
        }
    }
    End {
        $Tasklet.AddToCollection("Tasklet")
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
        Write-Output "Tasklet Saved"
    }
}

function Get-Tasklet {
    [cmdletbinding()]
    param(
        $Tags,
        [switch]$FormatView
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {(Get-LifeTrackerConfig).values}
        return  Get-DynamicParam -Validate -ParamName Value -ParamCode $ConfigValues
    }

    begin {
        $Value = $PsBoundParameters['Value']

        Import-Module PSLiteDB | Out-Null
        $OutputArray = @()
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    process {
        $GetDocuments = Find-LiteDBDocument -Collection "tasklet"
        if ($Tags){
            $GetDocuments = $GetDocuments | where Tags -Contain $Tags
        }
        if ($Value){
            $GetDocuments = $GetDocuments | where Value -Contains $Value
        }
        
        foreach ($Document in $GetDocuments){
            $OutputArray += [tasklet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            if ($FormatView){
                $OutputArray | Sort Priority -Descending | Select Title,Value,Tags,Complexity
            }
            else {
                $OutputArray | Sort Priority -Descending
            }
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
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {(Get-LifeTrackerConfig).values}
        return  Get-DynamicParam -Validate -ParamName Value -ParamCode  $ConfigValues
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
            Write-Host -ForegroundColor Yellow "`nPlease enter Priority 0,1,2,3,5,8,13,21,34,55 or press return`n------"
            foreach($Index in 0..$($AllTasklets.count-1)){
                do {
                    $Title = $AllTasklets[$Index].Title
                    while ($Priority -notin @(0,1,2,3,4,5)){
                        [int]$Priority  = Read-Host $Title
                    }
                    if ($AllTasklets.count -gt 1){
                        $PerTaskletDecrease = $Priority / ($AllTasklets.count-1)
                    }
                    else {
                        $PerTaskletDecrease = 0
                    }
                }
                until (
                    $Priority -ge 0 -AND $Priority -le 5
                )
                
                $AllTasklets[$Index].Priority += ($Priority + $PerTaskletDecrease)
                foreach($Index in 0..$($AllTasklets.count-1)){
                    $AllTasklets[$Index].Priority -= $PerTaskletDecrease
                }
            }
        }
    }
    end {
        if ($AllTasklets){
            foreach ($Index in 0..$($AllTasklets.count-1)) {
                $AllTasklets[$Index].UpdateCollection("tasklet")
            }
            $AllTasklets
            Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
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

    begin{}
    process{
        try{
            $InputObject.MoveToCollection("tasklet_archive")
            Write-Output "Tasklet [$($InputObject.title)] Completed"
        }
        catch {
            Write-Error "Error occurred uploading or deleting object from archive, error: $($error[0].exception.message)"
            Close-LiteDBConnection | Out-Null
        }
    }
    end{
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
    }
}

function Remove-Tasklet {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline=$true)]$InputObject
    )

    begin{}
    process{
        try{
            $InputObject.RemoveFromCurrentCollection()
            Write-Output "Tasklet [$($InputObject.title)] Removed"
        }
        catch {
            Write-Error "Error occurred deleting object from archive, error: $($error[0].exception.message)"
            Close-LiteDBConnection | Out-Null
        }
    }
    end{

    }
}