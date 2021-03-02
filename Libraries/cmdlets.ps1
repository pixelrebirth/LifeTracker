function Add-Tasklet {
    [cmdletbinding()]
    Param (
        $Title,
        $Tags
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
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
        $Tasklet.AddToCollection("Tasklet")
        Write-Output "Tasklet Saved"
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
        "journlet",
        "journlet_archive",
        "timelet",
        "timelet_archive",
        "habitlet",
        "habitlet_archive",
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

function Get-Tasklet {
    [cmdletbinding()]
    param(
        $Tags,
        [switch]$FormatView
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
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
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
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
    end{}
}

function New-Rewardlet {
    param(
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)]$TimeEstimate,
        [parameter(Mandatory=$true)]$DopamineIndex
    )
    begin {
        Import-Module PSLiteDB | Out-Null
        $Rewardlet = [rewardlet]::new($Title,$TimeEstimate,$DopamineIndex)
    }
    process {
        $Rewardlet.AddToCollection("rewardlet")
    }
    end {
        "Rewardlet Created"
    }
}

function Add-Rewardlet {
    [CmdletBinding()]
    param (
        
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "rewardlet").Title
            Close-LiteDBConnection | Out-Null
        }
        return Get-DynamicParam -ParamName Title -ParamCode $ConfigValues
    }
    
    begin {
        $Title = $PsBoundParameters['Title']
        
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    process {
        $PossibleRewards = Find-LiteDBDocument -Collection "rewardlet"
        Close-LiteDBConnection | Out-Null

        $IncreaseTaskRequirement = ($PossibleRewards | Where title -eq $Title).TaskRequirement * .05 #percentage increase, to config?
        $DecreaseTaskRequirement = $IncreaseTaskRequirement / ($PossibleRewards.count-1)

        foreach ($Reward in $PossibleRewards) {
            if ($Reward.Title -eq $Title){
                $Reward.TaskRequirement = $Reward.TaskRequirement + $IncreaseTaskRequirement
                $Transaction = [rewardlet]::new($Reward)
                $Transaction.UpdateCollection("rewardlet")
            }
            else {
                $Reward.TaskRequirement = $Reward.TaskRequirement - $DecreaseTaskRequirement
                $ReduceReward = [rewardlet]::new($Reward)
                $ReduceReward.UpdateCollection("rewardlet")
            }
        }
    }
    
    end {
        try {
            $Transaction._id = (New-Guid).Guid
            $Transaction.AddToCollection("rewardlet_transaction")
        }
        catch {
            throw "Failed to update rewardlet_transaction"
        }
        "Rewardlet Registered as Taken"
    }
}

function Get-RewardletTransaction {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    
    process {
        $Output = Find-LiteDBDocument -Collection "rewardlet_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
        $Output
    }
}

function Get-Rewardlet {
    [cmdletbinding()]
    param(
        [switch]$FormatView
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "rewardlet").Title
            Close-LiteDBConnection | Out-Null
        }
        return Get-DynamicParam -ParamName Title -ParamCode $ConfigValues
    }

    begin {
        $Title = $PsBoundParameters['Title']

        Import-Module PSLiteDB | Out-Null
        $OutputArray = @()
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    process {
        $GetDocuments = Find-LiteDBDocument -Collection "rewardlet"
        if ($Title){
            $GetDocuments = $GetDocuments |  where Title -Contain $Title
        }

        foreach ($Document in $GetDocuments){
            $OutputArray += [rewardlet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            if ($FormatView){
                $OutputArray | Sort Weight -Descending | Select Title,TimeEstimate,DopamineIndex,TaskRequirement
            }
            else {
                $OutputArray | Sort Weight -Descending
            }
        }
        else {
            "No Rewardlet Found"
        }
    }
}