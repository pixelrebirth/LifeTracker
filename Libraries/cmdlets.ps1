function Add-Tasklet {
    [cmdletbinding()]
    Param (
        $Title,
        $Tags
    )
    DynamicParam {
        . $global:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
    }
    Begin{
        $Value = $PsBoundParameters['Value']
    }
    Process {
        $Tasklet = [Tasklet]::new($Title,$Value)
        if ($Tags){
            $Tasklet.tags = @($Tags.split(','))
        }
    }
    End {
        $Tasklet.AddToDb()
        Write-Output "Tasklet Saved"
    }
}

function New-TaskletDatabase {
    param(
        $Path = $global:DatabaseLocation
    )
    Import-Module PSLiteDB | Out-Null
    
    $WarningPreference = 'SilentlyContinue'

    New-LiteDBDatabase -Path $Path | Out-Null
    Open-LiteDBConnection -Path $Path | Out-Null
    New-LiteDBCollection "tasklets" | Out-Null
    New-LiteDBCollection "tasklets_archive" | Out-Null
    Close-LiteDBConnection
    
    if (Test-Path $Path){
        return $Path
    }
    else {
        return $false
    }
}

function Get-Tasklet {
    Import-Module PSLiteDB | Out-Null
    $OutputArray = @()

    Open-LiteDBConnection $global:DatabaseLocation | Out-Null
    $GetDocuments = Find-LiteDBDocument -Collection "tasklets"
    Close-LiteDBConnection | Out-Null
    
    foreach ($Document in $GetDocuments){
        $OutputArray += [tasklet]::new($Document)
    }

    $OutputArray | Sort Weight -Descending
}

function Register-TaskletTouch {
    [cmdletbinding()]
    param(
        $Tags,
        $Value
    )
    begin{
        $AllTasklets = Get-Tasklet -Tags $Tags -Value $Value
    }
    process {
        Write-Host -ForegroundColor Yellow "`nPlease enter weight 1-5 or press return`n------"
        foreach($Index in 0..$($AllTasklets.count-1)){
            do {
                $Title = $AllTasklets[$Index].Title
                [int]$Weight  = Read-Host $Title
                if ($AllTasklets.count -gt 1){
                    $PerTaskletDecrease = $Weight / ($AllTasklets.count-1)
                }
                else {
                    $PerTaskletDecrease = 0
                }
            }
            until (
                $Weight -ge 0 -AND $Weight -le 5
            )
            
            $AllTasklets[$Index].weight += ($Weight + $PerTaskletDecrease)
            foreach($Index in 0..$($AllTasklets.count-1)){
                $AllTasklets[$Index].weight -= $PerTaskletDecrease
            }
        }
    }
    end {
       foreach ($Index in 0..$($AllTasklets.count-1)) {
            $AllTasklets[$Index].UpdateDb()
        }
        Get-Tasklet -Tags $Tags -Value $Value
    }
}

function Update-Tasklet {
    param(
        $Title,
        $Tags,
        $Value
    )
}
function Complete-Tasklet {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline=$true)]$InputObject
    )

    begin{
        Open-LiteDBConnection $global:DatabaseLocation | Out-Null
    }
    process{
        try{
            $InputObject | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection "Tasklets_Archive"
            Find-LiteDbDocument -collection "tasklets" -id $InputObject._id | Remove-LiteDbDocument
            Write-Output "Tasklet [$($InputObject.title)] Completed"
        }
        catch {
            throw "Error occurred uploading or deleting object from archive, error: $($error[0].exception.message)"
        }
    }
    end{
        Close-LiteDBConnection | Out-Null
    }
}