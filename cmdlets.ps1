function Add-Tasklet {
    Param (
        $Title,
        $Value
    )
    DynamicParam {
        . ./functions.ps1
        . ./classes.ps1
        
        [Scriptblock]$ScriptBlock = {Get-TaskletValues}
        return Get-DynamicParam -ParamName Values -ParamCode $ScriptBlock
    }
    Begin{
        $Tasklet = [Tasklet]::new($Title,$Value)
    }
    Process {
        
    }
    End {
        try {
            $Tasklet.AddToDb()
            Write-Output "Tasklet Saved"
        } catch {
            Write-Error "Cannot upload to Tasklet DB"
        }
    }
}

function New-TaskletDatabase {
    param(
        $Path = "./tasklet.db",
        $Force
    )
    Import-Module PSLiteDB | Out-Null
    
    New-LiteDBDatabase -Path $Path | Out-Null
    Open-LiteDBConnection -Path $Path | Out-Null
    New-LiteDBCollection "tasklets" | Out-Null

    try {
        Get-LiteDBIndex -Collection "tasklets" | Out-Null
        Close-LiteDBConnection
        return $True
    }
    catch {
        Close-LiteDBConnection
        return $False
    }
}