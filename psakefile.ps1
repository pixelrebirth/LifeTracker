Import-Module Psake

properties {
    $Message
}

Task default -depends Commit

Task Commit -Depends Testing {
    if (!$Message){$Message = "Auto-$((get-date) -replace(" |:|/","-"))"}
    
    git add -A
    git commit -m $Message
    git push
}

Task Testing {
    $pester = Invoke-Pester -PassThru
    Assert (
        $pester.FailedCount -eq 0
    ) "Cannot Complete Build Failures: $($pester.FailedCount) Coverage: NaN"
}

# Add conditional builds for Build(test)/Minor(dev)/Major(prod)
# Include DB version control to not risk losing prod
# Consider migration of data, even from a regeneration perspective may improve maintainability
# Version control with Major.Minor.Build format in PSD1 file
# Squash Commit on Release