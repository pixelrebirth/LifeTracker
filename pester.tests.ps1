. ./functions.ps1
. ./classes.ps1
. ./cmdlets.ps1

describe "LifeTrackerFunctions" {

}

describe "LifeTrackerClasses" {
    $tasklet = [tasklet]::new("Test Title","productivity")
    it "Should instantiate an object with repeat of Once" {
        $tasklet.repeat | should be "Once"
    }
}

describe "LifeTrackerCmdlets" {
    Remove-Item ./tasklet.db -force
    it "Should create a database for the App" {
        New-TaskletDatabase ./tasklet.db | should be $true
    }
    
    it "Should upload a document to DB" {
        Add-Tasklet -Value Testing -Title "Testing Length" | Should Be "Tasklet Saved"
    }

    it "Should retrieve the tasklet from DB" {

    }
}
