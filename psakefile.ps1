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

# Add conditional builds for Build(test)/Minor(dev)/Major(prod)
# Include DB version control to not risk losing prod
# Consider migration of data, even from a regeneration perspective may improve maintainability
# Version control with Major.Minor.Build format in PSD1 file
# Squash Commit on Release