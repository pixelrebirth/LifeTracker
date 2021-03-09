function New-Rewardlet {
    param(
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)]$TimeEstimate,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)]$DopamineIndex,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)]$TaskRequirement
    )
    begin {
        Import-Module PSLiteDB | Out-Null
        $Rewardlet = [rewardlet]::new($Title,$TimeEstimate,$DopamineIndex,$TaskRequirement)
    }
    process {
        $Rewardlet.AddToCollection("rewardlet")
    }
    end {
        "Rewardlet Created"
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
    }
}

function Add-Rewardlet {
    [CmdletBinding()]
    param (
        
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
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
        $Reward = Find-LiteDBDocument -Collection "rewardlet" | Where title -eq $Title
        Close-LiteDBConnection | Out-Null

        if ($Reward.count -eq 1){
            $Transaction = [rewardlet]::new($Reward)
            $Transaction.UpdateCollection("rewardlet")
        }
        else {
            throw "Too many rewards with same title: $Title"
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
        . $script:LifeTrackerModulePath/Libraries/general.ps1
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
                $OutputArray | Sort Priority -Descending | Select Title,TimeEstimate,DopamineIndex,TaskRequirement
            }
            else {
                $OutputArray | Sort Priority -Descending
            }
        }
        else {
            "No Rewardlet Found"
        }
    }
}