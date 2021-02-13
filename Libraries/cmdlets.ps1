function Add-Tasklet {
    [cmdletbinding()]
    Param (
        $Title,
        $Tags
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
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
        $Path = $script:DatabaseLocation
    )
    Import-Module PSLiteDB | Out-Null
    
    $WarningPreference = 'SilentlyContinue'

    New-LiteDBDatabase -Path $Path | Out-Null
    Open-LiteDBConnection -Path $Path | Out-Null
    
    $Collections = @(
        "tasklets",
        "rewardlets",
        "journlets",
        "timelets",
        "habitlets",
        "blob"
    )

    foreach ($Item in $Collections){
        New-LiteDBCollection "$item" | Out-Null
        New-LiteDBCollection "$($item)_archive" | Out-Null
    }

    Close-LiteDBConnection
    
    if (Test-Path $Path){
        return "$Path Exists"
    }
    else {
        return $false
    }
}

function Get-Tasklet {
    [cmdletbinding()]
    param(
        $Tags,
        [switch]$FormatView
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
    }

    begin {
        $Value = $PsBoundParameters['Value']

        Import-Module PSLiteDB | Out-Null
        $OutputArray = @()
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    process {
        $GetDocuments = Find-LiteDBDocument -Collection "tasklets"
        if ($Tags){
            $GetDocuments = $GetDocuments |  where Tags -Contain $Tags
        }
        if ($Value){
            $GetDocuments = $GetDocuments |  where Value -Contains $Value
        }
        
        foreach ($Document in $GetDocuments){
            $OutputArray += [tasklet]::new($Document)
        }
    }
    end {
        Close-LiteDBConnection | Out-Null
        if ($OutputArray){
            if ($FormatView){
                $OutputArray | Sort Weight -Descending | Select Title,Weight,Value,Tags
            }
            else {
                $OutputArray | Sort Weight -Descending
            }
        }
        else {
            "No Tasklets Found"
        }
    }
}

function Register-TaskletTouch {
    [cmdletbinding()]
    param(
        $Tags
    )
    DynamicParam {
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
        [Scriptblock]$ConfigValues = {(Get-TaskletConfig).values}
        return Get-DynamicParam -ParamName Value -ParamCode $ConfigValues
    }

    begin{
        $Value = $PsBoundParameters['Value']

        $AllTasklets = Get-Tasklet
        if ($Tags){
            $AllTasklets = $AllTasklets |  where Tags -Contain $Tag
        }
        if ($Value){
            $AllTasklets = $AllTasklets |  where Value -Contains $Value
        }
    }
    process {
        if ($AllTasklets){
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
    }
    end {
        if ($AllTasklets){
            foreach ($Index in 0..$($AllTasklets.count-1)) {
                $AllTasklets[$Index].UpdateDb()
            }
            $AllTasklets
        }
        else {"No Tasklets Found"}
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

    begin{}
    process{
        try{
            $InputObject.archive()
            Write-Output "Tasklet [$($InputObject.title)] Completed"
        }
        catch {
            Write-Error "Error occurred uploading or deleting object from archive, error: $($error[0].exception.message)"
            Close-LiteDBConnection | Out-Null
        }
    }
    end{}
}

function Add-RewardLet {
    #Add rewards like tasklets, weight included as "cost", 100 base
    #Increase Cost on use, borrowing accordingly from other rewards like tasklet weight does
    #Cost increase is based on Tasklet Active pool, more tasks, more cost increase on favorite rewards
    #Designer Rewards and Experiences
    #Variable cost metrics, ChronoTokens, WillpowerTokens, or TaskTokens
    #Track on
}

function New-LifeTrackerCharacter {
    param(
        $Name="Alia Stormchild"
    )
    
    $Character = [Character]::new($Name)
    try {
        $Character.AddToDb()
        "Added Character Successfully"
    }
    catch {
        "Could not add character to database"
    }
    
}

function Get-LifeTrackerCharacter {
    param(
        $Name="Alia Stormchild"
    )

    $Character = [Character]::new($Name)
}