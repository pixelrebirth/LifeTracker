function Get-LifeTracker {
    [CmdletBinding()]
    param (
        [switch]$Full
    )
    
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection $script:DatabaseLocation | Out-Null
    }
    
    process {
        $Output = Find-LiteDBDocument -Collection "token_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
        if(!$Full){
            $Sum = $Output | Measure-Object -Sum -Property WillpowerToken,ChronoToken,TaskToken
            $Output = [PSCustomObject]@{
                WillpowerToken = ($Sum | Where Property -eq WillpowerToken).sum
                ChronoToken = ($Sum | Where Property -eq ChronoToken).sum
                TaskToken = ($Sum | Where Property -eq TaskToken).sum
            }
        }
        $Output
    }
}

function Get-DynamicParam {
    Param ([array]$ParamName,[array]$ParamCode,[switch]$Validate)

    $Count = 0
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

    $ParamName | foreach {
        
        $Name = $_
        $Scriptblock = $ParamCode[$count]
        $ParameterName = $Name
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $AttributeCollection.Add($ParameterAttribute)

        if ($Validate){
            $arrSet = . $Scriptblock
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            $AttributeCollection.Add($ValidateSetAttribute)
        }

        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        $count++
    }
    return $RuntimeParameterDictionary
}

function Get-LifeTrackerConfig {
    Get-Content "$script:LifeTrackerModulePath/config.json" | ConvertFrom-Json
}

function Add-LifeTrackerTransaction {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]$FunctionName,
            $TaskToken,
            $WillpowerToken,
            $ChronoToken,
            $DbPath = $script:DatabaseLocation        
        )
        
    begin {
        Import-Module PSLiteDB | Out-Null
        Open-LiteDBConnection -Path $DbPath | Out-Null
        $Config = Get-LifeTrackerConfig

        $CheckState = !$TaskToken -OR !$WillpowerToken -OR !$ChronoToken
        if ($CheckState) {
            $TransactionRatio = $Config.TransactionRatio.$FunctionName.split(':')
        }
    }
    
    process {
        if ($CheckState) {
            $Data = [PSCustomObject]@{
                Cmdlet            = $FunctionName
                WillpowerToken    = $TransactionRatio[0]
                ChronoToken       = $TransactionRatio[1]
                TaskToken         = $TransactionRatio[2]
                Ticks             = (Get-Date).Ticks
            }
        }
        else {
            $Data = [PSCustomObject]@{
                Cmdlet            = $FunctionName
                WillpowerToken    = [int]$WillpowerToken
                ChronoToken       = [int]$ChronoToken
                TaskToken         = [int]$TaskToken
                Ticks             = (Get-Date).Ticks
            }
        }
        $Data | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection "token_transaction"
    }
    
    end {
        Close-LiteDBConnection | Out-Null
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
        "tasklet",
        "tasklet_archive",
        "rewardlet",
        "rewardlet_transaction",
        "journlet_transaction",
        "countlet_transaction",
        "timelet",
        "timelet_transaction",
        "habitlet",
        "habitlet_transaction",
        "token_transaction"
    )

    foreach ($Item in $Collections){
        New-LiteDBCollection "$item" | Out-Null
    }

    Close-LiteDBConnection
    
    if (Test-Path $Path){
        return "$Path Exists"
    }
    else {
        return $false
    }
}

function Optimize-Database {}

function Reset-LifeTrackerTransactionCollection {
    [CmdletBinding()]
    param (
        [switch]$AcceptResponsibility,
        $DbPath = $script:DatabaseLocation
    )
    
    begin {
        if (!$AcceptResponsibility){
            Write-Output "This is a dangerous cmdlet, you must accept responsibility."
            # Automatic Backup
            Break
        }
    }
            
    process {
        Open-LiteDBConnection -Path $DbPath | Out-Null
        Remove-LiteDBCollection "token_transaction" -Confirm:$False
        New-LiteDBCollection "token_transaction"
        Close-LiteDBConnection
    }
    
    end {
        Write-Output "LifeTracker Level Zero Activated"
    }
}

function Backup-LifeTrackerDatabase {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $LastBackup = Get-ChildItem $script:DatabaseBackupLocation *backup*.db | where lastwritetime -gt (get-date).adddays(-1)
        $Path = "$($script:DatabaseBackupLocation)LifeTracker_backup_$((Get-Date).ticks).db"
    }
    
    process {
        try {
            if ($LastBackup.count -eq 0){
                Copy-Item $script:DatabaseLocation $Path
                "$Path has been created. Thank you."
            }
        }
        catch {
            Write-Error "Cannot copy $script:DatabaseLocation to $Path"
        }
    }

    end {

    }
}

function Start-LifeTrackerRestApi {
    [CmdletBinding()]
    param (
        $Path = "$script:LifeTrackerModulePath/RestPS/endpoints/RestPSRoutes.json",
        $Port = 1001
    )
    
    begin {
        Import-Module RestPS -force
    }
    
    process {
        Start-Job {
            Param($Path,$Port)
            Start-RestPSListener -RoutesFilePath $Path -Port $Port
        } -ArgumentList $Path,$Port
    }
    
    end {
        
    }
}

function Start-LifeTrackerGui {
    param()
    begin {

    }
    process {
        while ($KeyPress -ne "g"){
            Clear-Host

            $Challenge = ""
            $ScheduledActivity = ""
            
            $LifeTracker = Get-LifeTracker
            $LifeTrackerAnalytics = Get-LifeTrackerAnalytics

            $WillpowerToken = $LifeTracker.WillpowerToken
            $WillpowerDiff = $LifeTrackerAnalytics.WillpowerTokenDiff
            $ChronoToken = $LifeTracker.ChronoToken
            $ChronoDiff = $LifeTrackerAnalytics.ChronoTokenDiff
            $TaskToken = $LifeTracker.TaskToken
            $TaskDiff = $LifeTrackerAnalytics.TaskTokenDiff
            $TotalToken = $LifeTracker.WillpowerToken + $LifeTracker.ChronoToken + $LifeTracker.TaskToken
            $TotalDiff = $LifeTrackerAnalytics.TotalDiff
            
            $StreakData = Get-LifeTrackerStreakData

            $Coins = 0
            
            Write-Output "
            ----- [LIFETRACKER] -----
            
            Bonus Challenge: [$Challenge]
            Scheduled Time:  [$ScheduledActivity]
            
            WillpowerToken: [$WillpowerToken|$WillpowerDiff]
            ChronoToken:    [$ChronoToken|$ChronoDiff]
            TaskToken:      [$TaskToken|$TaskDiff]
            TotalDiff:      [$TotalToken|$TotalDiff]
            
            Tasklet   [$($StreakData.TaskStreak)]:[$($StreakData.TaskDots)]
            Habitlet  [$($StreakData.HabitStreak)]:[$($StreakData.HabitDots)]
            Rewardlet [$($StreakData.RewardStreak)]:[$($StreakData.RewardDots)]
            Journlet  [$($StreakData.JournStreak)]:[$($StreakData.JournDots)]
            Timelet   [$($StreakData.TimeStreak)]:[$($StreakData.TimeDots)]
            Countlet  [$($StreakData.CountStreak)]:[$($StreakData.CountDots)]
            
            BossToken [$($StreakData.BossToken)]:[$($StreakData.BossDots)]
            Experience    []
            Coins     [$Coins]
        
            ----- [KEYBINDINGS] -----

            [A] New-Tasklet
            [W] Get-Tasklet
            [S] Register-TaskletTouch
            [D] Add-Journlet

            [Z] Willpower
            [X] Box Breathing
            [C] Observation Self
            [R] Refresh Screen

            [Q] Add-Habitlet
            [E] Add-Timelet
            [R] Refresh
            [F] Focus Mode

            [1] Buy Reward Spin
            [2] Consume Reward
            [3] Challenge Complete
            [4] Scheduled Time Used

            [G] Quit
            
            ----- [END] -----
            "

            $Regex = '1|2|3|4|q|w|e|r|a|s|d|f|g|z|x|c' 
            $HostOutput = $null

            $KeyPress = Get-KeyPress -Message "LifeTracker:>" -timeOutMilliSeconds 30000 -regexPattern $Regex
            Clear-Host
            Start-Sleep -Milliseconds 250
            
            if ($KeyPress -match $Regex) {
                $HostOutput = switch ($KeyPress){
                    "a" {New-Tasklet}
                    "w" {Get-Tasklet -ComplexSort -PrioritySort -Tags "$(Read-Host Tags)"}
                    "s" {Register-TaskletTouch -Tags "$(Read-Host Tags)"}
                    "d" {Add-Journlet}
                    
                    "z" {Add-Countlet -Title "Willpower" -Tags 'willpower'}
                    "x" {Add-Countlet -Title "Box Breathe" -Tags 'box-breathe'}
                    "c" {Add-Countlet -Title "Observation Self" -Tags 'observation-self'}
                    
                    "q" {Add-Habitlet -Match "$(Read-Host Match)"}
                    "e" {Add-Timelet -Match "$(Read-Host Match)"}
                    "r" {} #Used for refresh
                    "f" {Set-LifetrackerFocus}
                    
                    "1" {Invoke-LifeTrackerSpin}
                    "2" {Receive-Rewardlet}
                    "3" {Complete-Challangelet}
                    "4" {Add-LifeTrackerSchedule -Type Daily}

                    "g" {break}
                }
                              
                Write-Output $HostOutput
                Read-Host "`nPress return to continue"
                Continue
            }
            Start-Sleep -Milliseconds 250
        }        
    }
    end {
 
    }   
}

function Get-LifeTrackerStreakData {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        #Create CMDLET type list dynamically somehow
        #Create $Output
    }
    
    process {
        #Each hour, I need to register each of the types
        #This data is in the token_transaciton table already
        #Pull each hour chunk from the data and see foreach cmdlet noun used at least once
        #Foreach make sure there is a * in the string EX: "*** * * ** *** *  * *   * **"
            #You will need to track the streak here, if ($CountWithNoBreak -gt $Streak){$Streak = $CountCountWithNoBreak;$Streak++;$}else{$CountWithNoBreak = 0; $Streak = 0}
        #Go back 24 hours
    }
    
    end {
        #Output
    }
}