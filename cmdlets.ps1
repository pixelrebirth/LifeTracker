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
    $OutputArray = @()

    Open-LiteDBConnection "./tasklet.db" | Out-Null
    $GetDocuments = Find-LiteDBDocument -Collection "tasklets"
    Close-LiteDBConnection | Out-Null
    
    foreach ($Document in $GetDocuments){
        $OutputArray += [tasklet]::new($Document)
    }

    $OutputArray
}

function Register-TaskletTouch {
    [cmdletbinding()]
    param()
    begin{
        $AllTasklets = Get-Tasklet
    }
    process {
        foreach($Index in 0..$($AllTasklets.count-1)){
            do {
                [int]$Weight  = Read-Host "[$($Tasklet.Title)]-Weight(1-5)"
                $PerTaskletDecrease = $Weight / $AllTasklets.count
            }
            until (
                $Weight -ge 0 -AND $Weight -le 5
            )
            if ($Weight -gt 0 -OR $Weight -le 5){
                $AllTasklets[$Index].weight += ($Weight + $PerTaskletDecrease)
            }
        }
        foreach($Index in 0..$($AllTasklets.count-1)){
            $AllTasklets[$Index].weight -= $PerTaskletDecrease
        }
    }
    end {
       foreach ($Index in 0..$($AllTasklets.count-1)) {
            $AllTasklets[$Index].UpdateDb($AllTasklets[$Index])
        }
    }
}