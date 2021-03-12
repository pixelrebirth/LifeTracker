function New-Habitlet {
    param(
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)]$Tags
    )
    begin {
        Import-Module PSLiteDB | Out-Null
        $Rewardlet = [habitlet]::new($Title,$Tags)
    }
    process {
        $Rewardlet.AddToCollection("habitlet")
    }
    end {
        "Habitlet Created"
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
    }
}

function Add-Habitlet {
    [CmdletBinding()]
    param (
        
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "habitlet").Title
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
        $Habitlet = Find-LiteDBDocument -Collection "habitlet" | Where Title -eq $Title
        Close-LiteDBConnection | Out-Null

        if ($Habitlet.count -eq 1){
            $Transaction = [habitlet]::new($Habitlet)
        }
        else {
            throw "Too many Habitlets returned from query"
        }
    }
    
    end {
        try {
            $Transaction._id = (New-Guid).Guid
            $Transaction.AddToCollection("habitlet_transaction")
        }
        catch {
            throw "Failed to update Habitlet_transaction"
        }
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
        "Habitlet Registered as Taken"
    }
}

function Get-HabitletTransaction {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    
    process {
        $Output = Find-LiteDBDocument -Collection "habitlet_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
        $Output
    }
}

function Get-Habitlet {
    [cmdletbinding()]
    param(
        [switch]$FormatView
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "habitlet").Title
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
        $GetDocuments = Find-LiteDBDocument -Collection "habitlet"
        if ($Title){
            $GetDocuments = $GetDocuments |  where Title -Contain $Title
        }

        foreach ($Document in $GetDocuments){
            $OutputArray += [habitlet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            $OutputArray | Sort Priority -Descending
        }
        else {
            "No Habitlet Found"
        }
    }
}