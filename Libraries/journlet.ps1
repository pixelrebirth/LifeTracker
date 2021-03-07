function Add-Journlet {
    [CmdletBinding()]
    param (
        $Title,
        $Tags
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        $Tags = @($Tags.split(','))
    }
    process {
        $Body = Read-Host "What do you need to talk about today"
        $Transaction = [Journlet]::new($Title,$Tags)
        $Transaction.Body = $Body
    }
    
    end {
        try {
            $Transaction.AddToCollection("journlet_transaction")
        }
        catch {
            throw "Failed to update journlet_transaction"
        }
        Add-LifeTrackerTransaction -ChronoToken 5 -WillpowerToken 0 -TaskToken ($Body.length / 5)
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
        if ($Output) {$Output}
        else {"No Journlet Found"}
    }
}