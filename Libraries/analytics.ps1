function Get-LifeTrackerAnalytics {
    [CmdletBinding()]
    param (
        [int]$DaysAgo = 7
    )
    
    begin {
        $TimePeriodBaseTicks = (Get-Date).AddDays(-$DaysAgo).Ticks
        $Data = Get-LifeTracker -Full | where ticks -gt $TimePeriodBaseTicks
        
        $Tokens = @(
            "WillpowerToken",
            "ChronoToken",
            "TaskToken"
        )
    }
    
    process {
        foreach ($TokenType in $Tokens){
            $AllTokens = $Data."$TokenType"
            $TokenObject = [PSCustomObject]@{
                NegativeTokens = $AllTokens | where {$_ -le 0} | Measure-Object -AllStats
                PositiveTokens = $AllTokens | where {$_ -gt 0} | Measure-Object -AllStats
                AllTokens = $AllTokens | Measure-Object -AllStats
            }   
            New-Variable -Name "$($TokenType)Data" -Value $TokenObject
        }
    }
    
    end {
        $Output = [PSCustomObject]@{
            WillpowerTokenDiff = 
                    [math]::round(
                      $willpowerTokenData.PositiveTokens.StandardDeviation- 
                      $WillpowerTokenData.NegativeTokens.StandardDeviation,
                      3
                    )
            ChronoTokenDiff = 
                    [math]::round(
                      $ChronoTokenData.PositiveTokens.StandardDeviation- 
                      $ChronoTokenData.NegativeTokens.StandardDeviation,
                      3
                    )
            TaskTokenDiff = 
                [math]::round(
                    $TaskTokenData.PositiveTokens.StandardDeviation- 
                    $TaskTokenData.NegativeTokens.StandardDeviation,
                    3
                )
            TotalDiff = 0
        }
        $Output.TotalDiff = 
              [math]::round($Output.WillpowerTokenDiff,3) +
              [math]::round($Output.ChronoTokenDiff,3) +
              [math]::round($Output.TaskTokenDiff,3)
        
        Write-Output $Output
    }
}