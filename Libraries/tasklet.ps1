function New-Tasklet {
    [cmdletbinding()]
    Param (
        $Title,
        [parameter(Mandatory=$true)]$Tags
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
    }
    Begin{
        $Value = $PsBoundParameters['Value']
        $Tags = @($Tags.split(','))
    }
    Process {
        $Tasklet = [Tasklet]::new($Title,$Tags)
        if ($Value){
            $Tasklet.Value = $Value
        }
    }
    End {
        $Tasklet.AddToCollection("Tasklet")
        Add-LifeTrackerTransaction -ChronoToken 3 -WillpowerToken 0 -TaskToken 0
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
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
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
                $OutputArray | Sort Weight -Descending | Select Title,Weight,Value,Tags
            }
            else {
                $OutputArray | Sort Weight -Descending
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
                $AllTasklets[$Index].UpdateCollection("tasklet")
            }
            $AllTasklets
            Add-LifeTrackerTransaction -ChronoToken 0 -WillpowerToken 3 -TaskToken 0
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
        Add-LifeTrackerTransaction -ChronoToken 0 -WillpowerToken 0 -TaskToken $InputObject.weight
    }
}
