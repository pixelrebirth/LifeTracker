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
        Add-LifeTrackerTransaction -ChronoToken 0 -WillpowerToken 2 -TaskToken 0
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
        Add-LifeTrackerTransaction -ChronoToken $(-$Transaction.TimeEstimate) -WillpowerToken $(-$Transaction.DopamineIndex) -TaskToken $(-$Transaction.TaskRequirement)
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