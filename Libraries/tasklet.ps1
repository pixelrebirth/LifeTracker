function New-Tasklet {
    [cmdletbinding()]
    Param (
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)]$Tags,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)]$Complexity,
        $RelatedTo
    )
    Begin{
        $Tags = @($Tags.split(','))
    }
    Process {
        $Tasklet = [Tasklet]::new($Title,$Tags,$Complexity)
        if ($RelatedTo){
            $Tasklet.RelatedTo = $RelatedTo
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
    begin {
        Import-Module PSLiteDB | Out-Null
        $OutputArray = @()
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    process {
        $GetDocuments = Find-LiteDBDocument -Collection "tasklet"
        if ($Tags){
            $GetDocuments = $GetDocuments | where Tags -Contain $Tags
        }
        
        foreach ($Document in $GetDocuments){
            $OutputArray += [tasklet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            if ($FormatView){
                $OutputArray | Sort Priority -Descending | Select Title,Tags,Complexity
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
    begin{
        $AllTasklets = Get-Tasklet
        if ($Tags){
            $AllTasklets = $AllTasklets |  where Tags -Contain $Tag
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
        $Tags
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

function Split-Tasklet {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline=$true)]$InputObject
    )
    begin{}
    process{
        try{
            New-Tasklet -Tags $InputObject.Tags -RelatedTo $InputObject.Title
            New-Tasklet -Tags $InputObject.Tags -RelatedTo $InputObject.Title
            $InputObject.RemoveFromCurrentCollection()
            Write-Output "Tasklet [$($InputObject.title)] Split"
        }
        catch {
            Write-Error "Error occurred deleting object from archive, error: $($error[0].exception.message)"
            Close-LiteDBConnection | Out-Null
        }
    }
    end{
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
    }

}