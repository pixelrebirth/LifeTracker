function New-Timelet {
    param(
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)]$Tags
    )
    begin {
        Import-Module PSLiteDB | Out-Null
        $Rewardlet = [timelet]::new($Title,$Tags)
    }
    process {
        $Rewardlet.AddToCollection("timelet")
    }
    end {
        "Timelet Created"
        Add-LifeTrackerTransaction -ChronoToken 2 -WillpowerToken 0 -TaskToken 0
    }
}

function Add-Timelet {
    [CmdletBinding()]
    param (
        
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "timelet").Title
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
        $Timelet = Find-LiteDBDocument -Collection "timelet" | Where Title -eq $Title
        Close-LiteDBConnection | Out-Null

        if ($Timelet.count -eq 1){
            $Transaction = [timelet]::new($Timelet)
        }
        else {
            throw "Too many Timelets returned from query"
        }
    }
    
    end {
        try {
            $Transaction._id = (New-Guid).Guid
            $Transaction.AddToCollection("timelet_transaction")
        }
        catch {
            throw "Failed to update timelet_transaction"
        }
        Add-LifeTrackerTransaction -ChronoToken $(-$Transaction.TimeEstimate) -WillpowerToken $(-$Transaction.DopamineIndex) -TaskToken $(-$Transaction.TaskRequirement)
        "Timelet Registered as Taken"
    }
}

function Get-TimeletTransaction {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    
    process {
        $Output = Find-LiteDBDocument -Collection "timelet_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
        $Output
    }
}

function Get-Timelet {
    [cmdletbinding()]
    param(
        [switch]$FormatView
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "timelet").Title
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
        $GetDocuments = Find-LiteDBDocument -Collection "timelet"
        if ($Title){
            $GetDocuments = $GetDocuments |  where Title -Contain $Title
        }

        foreach ($Document in $GetDocuments){
            $OutputArray += [timelet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            $OutputArray | Sort Weight -Descending
        }
        else {
            "No Timelet Found"
        }
    }
}