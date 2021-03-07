function Add-Journlet {
    [CmdletBinding()]
    param (
        
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/general.ps1
        [Scriptblock]$ConfigValues = {
            Import-Module PSLiteDB | Out-Null
            Open-LiteDBConnection $script:DatabaseLocation | Out-Null
            (Find-LiteDBDocument -Collection "journlet").Title
            Close-LiteDBConnection | Out-Null
        }
        return Get-DynamicParam -ParamName Title -ParamCode $ConfigValues
    }
    
    begin {
        $Title = $PsBoundParameters['Title']
        
        Import-Module PSLiteDB | Out-Null
    }
    process {
        if ($Journlet.count -eq 1){
            $Transaction = [Journlet]::new($Journlet)
        }
        else {
            throw "Too many  returned from query"
        }
    }
    
    end {
        try {
            $Transaction._id = (New-Guid).Guid
            $Transaction.AddToCollection("journlet_transaction")
        }
        catch {
            throw "Failed to update journlet_transaction"
        }
        Add-LifeTrackerTransaction -ChronoToken 0 -WillpowerToken 0 -TaskToken 15
        "Journlet Registered as Taken"
    }
}

function Get-Journlet {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    
    process {
        $Output = Find-LiteDBDocument -Collection "journlet_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
        $Output
    }
}