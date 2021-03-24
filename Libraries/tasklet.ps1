function New-Tasklet {
    [cmdletbinding()]
    [Alias("nt")]
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
    [Alias("gt")]
    param(
        $Tags,
        [string]$Match,
        [switch]$ComplexSort,
        [switch]$PrioritySort
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
        if ($Match){
            $GetDocuments = $GetDocuments | where title -match $Match
        }
        
        foreach ($Document in $GetDocuments){
            $OutputArray += [tasklet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            if ($ComplexSort){
                $OutputArray | Sort Priority -Descending  | sort complexity,title |  select title,complexity
            }
            elseif ($PrioritySort){
                $OutputArray | Sort Priority -Descending  | sort priority,title |  select title,priority
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
    [Alias("rtt")]
    param(
        $Tags
    )
    begin{
        $AllTasklets = Get-Tasklet
        if ($Tags){
            $AllTasklets = $AllTasklets | where Tags -Contain $Tags
        }
    }
    process {
        if ($AllTasklets){
            Write-Host -ForegroundColor Yellow "`nPlease enter Priority 0,1,2,3,4,5,c,r or press return`n------"
            foreach($Index in 0..$($AllTasklets.count-1)){
                do {
                    $Title = $AllTasklets[$Index].Title
                    $Priority = -1

                    while ($Priority -notin @(0,1,2,3,4,5,"c","r")){
                        $Priority  = Read-Host $Title
                        switch ($priority){
                            "c" {
                                $AllTasklets[$Index] | Complete-Tasklet
                            }
                            "r" {
                                $AllTasklets[$Index] | Remove-Tasklet
                            }
                        }
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
                
                $AllTasklets[$Index].Priority += ([int]$Priority + $PerTaskletDecrease)
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
    #Using input object, rehydrate the object and invoke update-litedbdocument
}
function Complete-Tasklet {
    [cmdletbinding()]
    [Alias("ct")]
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
    [Alias("rt")]
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
        [parameter(ValueFromPipeline=$true)]$InputObject,
        $NumberSplit = 2
    )
    begin{
        if ($NumberSplit -lt 2){
            $NumberSplit = 2
        }
    }
    process{
        try{
            1..$NumberSplit | foreach {
                New-Tasklet -Tags $InputObject.Tags -RelatedTo $InputObject.Title
            }

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