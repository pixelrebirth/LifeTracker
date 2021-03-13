function Add-Journlet {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]$WritingPrompt,
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)]$Tags
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        $Tags = @($Tags.split(','))
    }
    process {
        $Transaction = [Journlet]::new($Title,$Tags)
        $Transaction.Body = $WritingPrompt
    }
    
    end {
        try {
            $Transaction.AddToCollection("journlet_transaction")
        }
        catch {
            throw "Failed to update journlet_transaction"
        }
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
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