describe "Local development execution" {
    $global:LifeTrackerModulePath = "."
    
    . ./Libraries/classes.ps1
    . ./Libraries/functions.ps1
    . ./Libraries/cmdlets.ps1

    context "LifeTrackerFunctions" {

    }

    context "LifeTrackerClasses" {
        $tasklet = [tasklet]::new("Test Title","Creativity")
        it "Should instantiate an object with repeat of Once" {
            $tasklet.title | should be "Test Title"
        }
    }

    context "LifeTrackerCmdlets" {
        Remove-Item $global:LifeTrackerModulePath/tasklet.db -Force -ErrorAction 0
        it "Should create a database for the App" {
            New-TaskletDatabase $global:LifeTrackerModulePath/tasklet.db | should be $true
        }

        it "Add-Tasklet uploads a document to DB" {
            Add-Tasklet -Value "Creativity" -Title "Create Tasklet 3" 
            Add-Tasklet -Value "Creativity" -Title "Create Tasklet 2"
            Add-Tasklet -Value "Creativity" -Title "Create Tasklet 1"  
            Add-Tasklet -Value "Leadership" -Title "Another Tasklet" | Should be "Tasklet Saved"
        }
        
        it "Get-Tasklet returns all tasklets by default" {
            (Get-Tasklet)[0].title | Should Match "Create Tasklet|Another Tasklet"
        }
        
        Mock Read-Host {return "3"}
        it "Register-TaskletTouch allocates 50 to Weight when Read-Host is 3" {
            (Register-TaskletTouch)[0].Weight | should be "50"
        }
    }
}