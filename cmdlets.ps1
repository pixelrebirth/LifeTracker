function Add-Tasklet {
    Param ()
    DynamicParam {
        . ./functions.ps1
        . ./classes.ps1
        
        [Scriptblock]$ScriptBlock = {Get-TaskletValues}
        return Get-DynamicParam -ParamName Values -ParamCode $ScriptBlock
    }
    Begin{
        $Tasklet = [Tasklet]::new()
    }
    Process {

    }
    End {

    }
}

function New-TaskletDb {
    param($Path)
    Import-Module PSLiteDB
    New-LiteDBDatabase -Path $Path
    return (Test-Path $Path)
}