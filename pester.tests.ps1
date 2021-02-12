describe "Local development execution" {
    $global:LifeTrackerModulePath = "."
    $global:DatabaseLocation = "./test.db"
    
    . ./Libraries/classes.ps1
    . ./Libraries/functions.ps1
    . ./Libraries/cmdlets.ps1

    context "LifeTrackerFunctions" {

    }

    context "LifeTrackerClasses" {
        $tasklet = [tasklet]::new("Test Title","Creativity")
        it "Should instantiate a tasklet class" {
            $tasklet.title | should be "Test Title"
            $tasklet.CreatedOn | Should Not Be Null
            $tasklet.UpdatedOn | Should Not Be Null
        }

        $rewardlet = [rewardlet]::new("Reward Me",5,5)
        it "Should instantiate a rewardlet class" {
            $rewardlet.title | should be "Reward Me"
        }
    }

    context "LifeTrackerCmdlets" {
        Remove-Item $global:DatabaseLocation -Force -ErrorAction 0
        it "Should create a database for the App" {
            New-TaskletDatabase | should be $true
        }

        it "Add-Tasklet uploads a document to DB" {
            Add-Tasklet -Value "Leadership" -Title "Another Tasklet" -Tags "Test,123"| Should be "Tasklet Saved"
            Add-Tasklet -Value "Systemic" -Title "Testing 123" | Should be "Tasklet Saved"
        }
        
        it "Get-Tasklet returns created tasklet" {
            (Get-Tasklet -FormatView -Tags "Test").title | Should Be "Another Tasklet"
            (Get-Tasklet -Value "Systemic").title | Should Be "Testing 123"
        }
        
        Mock Read-Host {return "3"}
        Mock Write-Host {}
        it "Register-TaskletTouch allocates 50 to Weight when Read-Host is 3" {
            (Register-TaskletTouch)[0].Weight | should be "50"
        }
        
        it "Register-TaskletTouch should filter down to only value/tag if asked" {
            Register-TaskletTouch -Value "Creativity" -Tags "Test" | Should Be "No Tasklets Found"
        }
        
        it "Should archive the tasklet created above" {
            (Get-Tasklet -Value "Systemic") | Complete-Tasklet | Should Be "Tasklet [Testing 123] Completed"
        }
    }
}