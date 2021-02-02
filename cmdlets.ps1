function Add-Tasklet {
    [cmdletbinding()]
    Param (
        $Title,
        $Tags
    )
    DynamicParam {
        . ./functions.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
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
    Import-Module PSLiteDB | Out-Null

    Open-LiteDBConnection "./tasklet.db" | Out-Null
    Find-LiteDBDocument -Collection "tasklets"
    Close-LiteDBConnection | Out-Null
}

function Register-TaskletTouch {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]$InputObject
    )
    begin{
    }
    process {
        foreach ($Tasklet in $InputObject){
            do {
                [int]$Weight  = Read-Host "[$($Tasklet.Title)]-Weight(1-5)"
            }
            until (
                $Weight -ge 0 -AND $Weight -le 5
            )
            if ($Weight -gt 0 -OR $Weight -le 5){
                Step-TaskletPriority -Weight $Weight -Id $Tasklet.Id
            }
        }
    }
    end {

    }
}