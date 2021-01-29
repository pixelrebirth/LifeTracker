function Add-Tasklet {
    [cmdletbinding()]
    Param (
        $Title
    )
    DynamicParam {
        . ./functions.ps1
        [Scriptblock]$ScriptBlock = {(Get-LifeTrackerConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ScriptBlock
    }
    Begin{
        $Value = $PsBoundParameters['Value']
    }
    Process {
        $Tasklet = [Tasklet]::new($Title,$Value)
    }
    End {
        $Tasklet.AddToDb()
        Write-Output "Tasklet Saved"
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
    Close-LiteDBConnection
    return $True
}

function Get-Tasklet {
    Open-LiteDBConnection "./tasklet.db" | Out-Null
    Find-LiteDBDocument -Collection "tasklets"
    Close-LiteDBConnection | Out-Null
}