. ./functions.ps1
. ./classes.ps1
. ./cmdlets.ps1

describe "LifeTrackerFunctions" {
    Remove-Item ./tasklet.db -force
    it "Should create a database for the App" {
        New-TaskletDatabase ./tasklet.db | should be $true
    }
}

describe "LifeTrackerClasses" {
    $tasklet = [tasklet]::new("Test Title","productivity")
    it "Should instantiate an object with repeat of Once" {
        $tasklet.repeat | should be "Once"
    }
}

describe "LifeTrackerCmdlets" {
    it "Add-Tasklet uploads a document to DB" {
        Add-Tasklet -Value "Charity" -Title "Testing Length" | Should Be "Tasklet Saved"
    }

    it "Get-Tasklet returns all tasklets by default" {
        (Get-Tasklet)[0].title | Should be "Testing Length"
    }
}
