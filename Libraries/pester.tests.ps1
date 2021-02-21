$global:LifeTrackerModulePath = $pwd.path
$global:DatabaseLocation = "./test.db"

describe "LifeTracker" {
    BeforeAll {
        . $global:LifeTrackerModulePath/Libraries/classes.ps1
        . $global:LifeTrackerModulePath/Libraries/functions.ps1
        . $global:LifeTrackerModulePath/Libraries/cmdlets.ps1
    
        Import-Module PSLiteDB
    }

    it "Should create a database for the App" {
        Remove-Item $global:DatabaseLocation -Force -ErrorAction 0
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

    # it "Should create a character in Database and Validate it" {
    #     (New-LifeTrackerCharacter).name | should -be "Alia Stormchild"
    # }
}