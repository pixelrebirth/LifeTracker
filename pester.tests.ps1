$script:LifeTrackerModulePath = $pwd.path
$script:DatabaseLocation = "./test.db"

describe "LifeTracker" {
    BeforeAll {
        . $script:LifeTrackerModulePath/Libraries/classes.ps1
        . $script:LifeTrackerModulePath/Libraries/functions.ps1
        . $script:LifeTrackerModulePath/Libraries/cmdlets.ps1
    
        Import-Module PSLiteDB
    }

    it "Should create a database for the App" {
        Remove-Item $script:DatabaseLocation -Force -ErrorAction 0
        New-TaskletDatabase | Should -BeTrue
    }

    it "Add-Tasklet uploads a document to DB" {
        Add-Tasklet -Value "Leadership" -Title "Another Tasklet" -Tags "Test,123"| Should -Be "Tasklet Saved"
        Add-Tasklet -Value "Systemic" -Title "Testing 123" | Should -Be "Tasklet Saved"
    }
    
    it "Get-Tasklet returns created tasklet" {
        (Get-Tasklet -FormatView -Tags "Test").title | Should -Be "Another Tasklet"
        (Get-Tasklet -Value "Systemic").title | Should -Be "Testing 123"
    }

    it "Register-TaskletTouch allocates 50 to Weight when Read-Host is 3" {
        Mock Read-Host {return "3"}
        Mock Write-Host {}

        (Register-TaskletTouch)[0].Weight | Should -Be "50"
    }
    
    it "Register-TaskletTouch should filter down to only value/tag if asked" {
        Mock Read-Host {return "3"}
        Mock Write-Host {}

        Register-TaskletTouch -Value "Creativity" -Tags "Test" | Should -Be "No Tasklets Found"
    }
    
    it "Should archive the tasklet created above" {
        (Get-Tasklet -Value "Systemic") | Complete-Tasklet | Should -Be "Tasklet [Testing 123] Completed"
    }

    it "Should upload a new rewardlet" {
        New-Rewardlet -Title "Testing Reward" -TimeEstimate 8 -DopamineIndex 3 | should -Be "Rewardlet Created"
    }

    it "Should Add-Rewardlet to the transaction database" {
        Add-Rewardlet -Title "Testing Reward" | Should -Be "Rewardlet Registered as Taken"
    }

    it "Should be able to pull a list of rewardlet transactions" {
        (Get-RewardletTransaction)[0].title | should -Be "Testing Reward"
    }
}