Import-Module Psake

Task default -depends Commit

Task Commit -Depends Testing {
    git add -A
    git commit -m "Auto-$((get-date) -replace(" |:|/","-"))"
    git push
}

Task Testing {
    $pester = Invoke-Pester -CodeCoverage ./Libraries/*.ps1
    $pester.FailedCount -eq 0 -AND 
        [int]$($pester.CodeCoverage.HitCommands.Count / $pester.CodeCoverage.NumberOfCommandsAnalyzed * 100) -ge 90
}
