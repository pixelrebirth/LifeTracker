function Add-Countlet {
    [CmdletBinding()]
    [Alias("aco")]
    param (
        [parameter(Mandatory=$true)]$Title,
        [parameter(Mandatory=$true)]$Tags
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        $Tags = @($Tags.split(','))
    }
    process {
        $Transaction = [countlet]::new($Title,$Tags)
    }
    
    end {
        try {
            $Transaction.AddToCollection("countlet_transaction")
        }
        catch {
            throw "Failed to update countlet_transaction"
        }
        Add-LifeTrackerTransaction -FunctionName $MyInvocation.MyCommand.Name
        "Countlet Registered as Taken"
    }
}

function Get-Countlet {
    [CmdletBinding()]
    [Alias("gco")]
    param (
        
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    
    process {
        $Output = Find-LiteDBDocument -Collection "countlet_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
        if ($Output) {$Output}
        else {"No Countlet Found"}
    }
}