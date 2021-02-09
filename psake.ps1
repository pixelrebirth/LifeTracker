Import-Module Psake

Task default -depends Commit

Task Commit -Depends Testing {
    git add -A
    git commit -m "Auto-$((get-date) -replace(" |:|/","-"))"
    git push
}

Task Testing {
    Invoke-Pester -CodeCoverage ./Libraries/*.ps1
}
