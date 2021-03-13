$script:LifeTrackerModulePath = $pwd.path
$script:DatabaseLocation = "./test.db"

describe "LifeTracker" {
    BeforeAll {
        $AllFiles = Get-ChildItem -Path "$script:LifeTrackerModulePath/Libraries/*.ps1" -Recurse -Exclude *.tests.*,RunPester.ps1
        $AllFiles | ForEach {. $Input}
    
        Import-Module PSLiteDB
    }

    it "Should create a database for the App" {
        Remove-Item $script:DatabaseLocation -Force -ErrorAction 0
        New-TaskletDatabase | Should -BeTrue
    }

    it "New-Tasklet uploads a document to DB" {
        New-Tasklet -Value "Leadership" -Title "Another Tasklet" -Tags "Test,123" -Complexity 21 | Should -Be "Tasklet Saved"
        New-Tasklet -Value "Systemic" -Title "Testing 123" -Tags "123" -Complexity 8 | Should -Be "Tasklet Saved"
    }
    
    it "Get-Tasklet returns created tasklet" {
        (Get-Tasklet -FormatView -Tags "Test").Title | Should -Be "Another Tasklet"
        (Get-Tasklet -Value "Systemic").Title | Should -Be "Testing 123"
    }

    it "Register-TaskletTouch allocates 50 to Priority when Read-Host is 3" {
        Mock Read-Host {return "3"}
        Mock Write-Host {}

        (Register-TaskletTouch)[0].Priority | Should -Be "50"
    }
    
    it "Register-TaskletTouch should filter down to only value/tag if asked" {
        Mock Read-Host {return "3"}
        Mock Write-Host {}

        Register-TaskletTouch -Value "Creativity" -Tags "Test" | Should -Be "No Tasklets Found"
    }
    
    it "Should archive the tasklet created above" {
        (Get-Tasklet -Value "Systemic") | Complete-Tasklet | Should -Be "Tasklet [Testing 123] Completed"
    }

    it "Should remove a tasklet with Remove-Tasklet" {
        (Get-Tasklet -Value "Leadership") | Remove-Tasklet | Should -Be  "Tasklet [Another Tasklet] Removed"
    }

    it "Should upload a new rewardlet" {
        New-Rewardlet -Title "More Testing" -TimeEstimate 5 -DopamineIndex 5 -TaskRequirement 5 | should -Be "Rewardlet Created"
        New-Rewardlet -Title "Testing Reward" -TimeEstimate 8 -DopamineIndex 8 -TaskRequirement 8 | should -Be "Rewardlet Created"
    }

    it "Should Add-Rewardlet to the transaction database" {
        Add-Rewardlet -Title "Testing Reward" | Should -Be "Rewardlet Registered as Taken"
    }

    it "Should be able to pull an available rewarlet" {
        $Rewardlet = Get-Rewardlet | Where Title -eq "Testing Reward"
        ($Rewardlet).Title | Should -Be "Testing Reward"
        ($Rewardlet).TaskRequirement | Should -Be 8

        $Rewardlet = Get-Rewardlet | Where Title -eq "More Testing"
        ($Rewardlet).Title | Should -Be "More Testing"
        ($Rewardlet).TaskRequirement | Should -Be 5
    }

    it "Should be able to pull a list of rewardlet transactions" {
        $Transaction = Get-RewardletTransaction | Where Title -eq "Testing Reward"
        $Transaction.TimeEstimate | should -Be 8
        $Transaction.DopamineIndex | should -Be 8
        $Transaction.Title | should -Be "Testing Reward"
    }
    
    it "Should upload a New-Timelet" {
        New-Timelet -Title "Time Registry" -Tags "Testing" | should -Be "Timelet Created"
        New-Timelet -Title "Time Check" -Tags "Testing" | should -Be "Timelet Created"
    }

    it "Should Add-Timelet to the transaction database" {
        Add-Timelet -Title "Time Check" | Should -Be "Timelet Registered as Taken"
    }

    it "Should be able to pull an available timelet" {
        (Get-Timelet | Where Title -eq "Time Check").Title | Should -Be "Time Check"
        (Get-Timelet | Where Title -eq "Time Registry").Title| Should -Be "Time Registry"
    }

    it "Should be able to pull a list of timelet transactions" {
        (Get-TimeletTransaction | Where Title -eq "Time Check").Title | should -Be "Time Check"
    }

    it "Should show sums for Get-LifeTracker" {
        (Get-LifeTracker -SumOnly).WillpowerToken | Should -Be 6
    }

    it "Should upload a New-Habitlet" {
        New-Habitlet -Title "Habit Registry" -Tags "Testing" | should -Be "Habitlet Created"
        New-Habitlet -Title "Habit Check" -Tags "Testing" | should -Be "Habitlet Created"
    }

    it "Should Add-Habitlet to the transaction database" {
        Add-Habitlet -Title "Habit Check" | Should -Be "Habitlet Registered as Taken"
    }

    it "Should be able to pull an available Habitlet" {
        (Get-Habitlet | Where Title -eq "Habit Check").Title | Should -Be "Habit Check"
        (Get-Habitlet | Where Title -eq "Habit Registry").Title| Should -Be "Habit Registry"
    }

    it "Should output a transaction log with Get-LifetrackerTransaction" {
        $Transactions = Get-LifeTracker -SumOnly
        $Transactions.ChronoToken| Should -Be 9
        $Transactions.TaskToken | Should -Be 14
        $Transactions.WillpowerToken| Should -Be 13
    }

    it "Should Add-Journlet to the transaction database" {
        Add-Journlet -Title "Journal Entry" -Tags "Test,123" -WritingPrompt "This is a journal entry." | Should -Be "Journlet Registered as Taken"
    }

    it "Should be able to pull an available Journlet" {
        (Get-Journlet | Where Title -eq "Journal Entry").Title | Should -Be "Journal Entry"
    }

    AfterAll {
        Remove-Item $script:DatabaseLocation -Force
    }
}