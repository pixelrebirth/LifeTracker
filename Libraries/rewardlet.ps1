function New-Rewardlet {
    [CmdletBinding()]
    [Alias("nr")]
    param(
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)][int]$TimeEstimate,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)][int]$DopamineIndex,
        [parameter(Mandatory=$true)][ValidateSet(0,1,2,3,5,8,13,21,34,55)][int]$TaskRequirement
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
    [Alias("ar")]
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
        return  Get-DynamicParam -Validate -ParamName Title -ParamCode  $ConfigValues
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
            $Transaction.AddToCollection("rewardlet_awarded")
        }
        catch {
            throw "Failed to update rewardlet_awarded"
        }
        
        #### UPDATED TO COINS METHOD, ADD COINS AND STATISTICS BLOB ####
        
        # $Splat = @{
        #     ChronoToken     = $(-$Transaction.TimeEstimate)
        #     WillpowerToken  = $(-$Transaction.DopamineIndex)
        #     TaskToken       = $(-$Transaction.TaskRequirement)
        #     FunctionName    = $MyInvocation.MyCommand.Name
        # }
        # Add-LifeTrackerTransaction @Splat

        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
        "Rewardlet [$($Transaction.title)] Award Won"
    }
}
function Receive-Rewardlet {
    [CmdletBinding()]
    [Alias("ar")]
    param (
        
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "rewardlet_awarded").Title
            Close-LiteDBConnection | Out-Null
        }
        return  Get-DynamicParam -Validate -ParamName Title -ParamCode  $ConfigValues
    }
    
    begin {
        $Title = $PsBoundParameters['Title']
        
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    process {
        $Reward = Find-LiteDBDocument -Collection "rewardlet_awarded" | Where title -eq $Title
        Close-LiteDBConnection | Out-Null

        if ($Reward.count -eq 1){
            $Transaction = [rewardlet]::new($Reward)
        }
        else {
            throw "Too many rewards with same title: $Title"
        }

        try {
            $Transaction.MoveCollection("rewardlet_awarded","rewardlet_transaction")
        }
        catch {
            throw "Failed to update rewardlet_awarded"
        }
    }
    
    end {
        $Splat = @{
            ChronoToken     = $(-$Transaction.TimeEstimate)
            WillpowerToken  = $(-$Transaction.DopamineIndex)
            TaskToken       = $(-$Transaction.TaskRequirement)
            FunctionName    = $MyInvocation.MyCommand.Name
        }
        Add-LifeTrackerTransaction @Splat

        "Rewardlet [$($Transaction.title)] Award Received"
    }
}
function Get-Rewardlet {
    [cmdletbinding()]
    [Alias("gr")]
    param(
        [switch]$FormatView,
        [ValidateSet('awarded','transaction','new')]$Type
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "rewardlet").Title
            Close-LiteDBConnection | Out-Null
        }
        return  Get-DynamicParam -Validate -ParamName Title -ParamCode  $ConfigValues
    }

    begin {
        $Title = $PsBoundParameters['Title']

        Import-Module PSLiteDB | Out-Null
        $OutputArray = @()
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    process {
        switch ($Type){
            "transaction"       {$GetDocuments = Find-LiteDBDocument -Collection "rewardlet_transaction"}
            "awarded"           {$GetDocuments = Find-LiteDBDocument -Collection "rewardlet_awarded"}
            default             {$GetDocuments = Find-LiteDBDocument -Collection "rewardlet"}
        }
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
