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
        if ($Title -match 'date'){
            $Title = Read-Host "Title cannot have date, retry"
        }
    }
    Process {
        $Tasklet = [Tasklet]::new($Title,$Tags,$Complexity)
        $Tasklet.CreatedOn = (Get-Date).Ticks
        $Tasklet.UpdatedOn = (Get-Date).Ticks
        
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
        Backup-LifeTrackerDatabase

        $OutputArray = @()
        
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
        $GetDocuments = Find-LiteDBDocument -Collection "tasklet"
        Close-LiteDBConnection | Out-Null
    }
    process {
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
        if ($OutputArray){
            if ($PrioritySort -AND $ComplexSort){
                $OutputArray | sort priority,complexity,title -Descending |  select title,priority,complexity
            }
            elseif ($PrioritySort){
                $OutputArray | sort priority,title  -Descending |  select title,priority
            }
            elseif ($ComplexSort){
                $OutputArray | sort complexity,title |  select title,complexity
            }
            else {
                $OutputArray | Sort priority
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
            Write-Host -ForegroundColor Yellow "`nPlease enter Priority 0,1,2,3,4,5,c,r,s or press return`n------"
            foreach($Index in 0..$($AllTasklets.count-1)){
                do {
                    $Title = $AllTasklets[$Index].Title
                    $Priority = -1

                    while ($Priority -notin @(0,1,2,3,4,5,"c","r","s")){
                        $Priority  = Read-Host $Title
                        switch ($priority){
                            "c" {
                                $AllTasklets[$Index] | Complete-Tasklet
                            }
                            "r" {
                                $AllTasklets[$Index] | Remove-Tasklet
                            }
                            "s" {
                                $AllTasklets[$Index] | Split-Tasklet
                            }
                        }
                    }
                    if ($Priority -notin @(1,2,3,4,5)){
                        $Priority = 0
                    }
                    if ($AllTasklets.count -gt 1){
                        $PerTaskletDecrease = [math]::round(
                            $Priority / ($AllTasklets.count-1),
                            3
                        )
                    }
                    else {
                        $PerTaskletDecrease = 0
                    }
                }
                until (
                    $Priority -ge 0 -AND $Priority -le 5
                )
                
                $AllTasklets[$Index].Priority += [math]::round(
                    ([int]$Priority + $PerTaskletDecrease),
                    3
                )
                foreach($Index in 0..$($AllTasklets.count-1)){
                    $AllTasklets[$Index].Priority -= [math]::round(
                        $PerTaskletDecrease,
                        3
                    )
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
    [cmdletbinding()]
    [Alias("ut")]
    param(
        [parameter(Mandatory = $true,ValueFromPipelineByPropertyName=$true)]$_id,
        $Title,
        $Complexity,
        $Priority,
        $CreatedOn,
        $UpdatedOn,
        $RelatedTo

    )
    begin{
        
    }
    process {
        $Tasklet = Get-Tasklet | where _id -eq $_id
        if ($Title) {$Tasklet.Title = $Title}
        if ($Complexity) {$Tasklet.Complexity = $Complexity}
        if ($Priority)  {$Tasklet.Priority = $Priority}
        if ($CreatedOn) {$Tasklet.CreatedOn = $CreatedOn}
        if ($UpdatedOn) {$Tasklet.UpdatedOn = $UpdatedOn}
        if ($RelatedTo) {$Tasklet.RelatedTo = $RelatedTo}
    }
    end {
        $Tasklet.UpdateCollection('tasklet')
    }
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
            Write-Error "Error with input object, you cannot use -ComplexSort or -PrioritySort on Get-Tasklet."
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
            Write-Error "Error with input object, you cannot use -ComplexSort or -PrioritySort on Get-Tasklet."
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
            Write-Error "Error with input object, you cannot use -ComplexSort or -PrioritySort on Get-Tasklet."
            Close-LiteDBConnection | Out-Null
        }
    }
    end{
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
    }

}