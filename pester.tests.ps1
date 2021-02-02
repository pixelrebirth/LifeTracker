. ./functions.ps1
. ./classes.ps1
. ./cmdlets.ps1

describe "LifeTrackerFunctions" {

}

describe "LifeTrackerClasses" {
    $tasklet = [tasklet]::new("Test Title","Creativity")
    it "Should instantiate an object with repeat of Once" {
        $tasklet.title | should be "Test Title"
    }
}

describe "LifeTrackerCmdlets" {
    Remove-Item ./tasklet.db -force
    it "Should create a database for the App" {
        New-TaskletDatabase ./tasklet.db | should be $true
    }

    it "Add-Tasklet uploads a document to DB" {
        Add-Tasklet -Value "Creativity" -Title "Create Tasklet" | Should Be "Tasklet Saved"
    }
    
    it "Get-Tasklet returns all tasklets by default" {
        (Get-Tasklet)[0].title | Should be "Create Tasklet"
    }
    
    Mock Read-Host {return "4"}
    it "Should do <something> when Register-TaskletTouch is piped into" {
        Get-Tasklet | Register-TaskletTouch | should match "weight increased by 4$"
    }
}
