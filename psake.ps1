Import-Module Psake

Task default -depends Testing

Task Testing -Depends Commit {
    Invoke-Pester -CodeCoverage ./Libraries/*.ps1
}

Task Commit {
    git add -A
    git commit -m "Auto-$((get-date) -replace(" |:|/","-"))"
    git push
}