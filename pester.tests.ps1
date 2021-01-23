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
    it "Should create a database for the App" {
        New-TaskletDb ./test.db | should be $true
        Remove-Item ./test.db -force
    }
}
