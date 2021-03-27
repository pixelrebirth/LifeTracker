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
        New-Tasklet -Title "Another Tasklet" -Tags "Test,123" -Complexity 21 | Should -Be "Tasklet Saved"
        New-Tasklet -Title "Testing 123" -Tags "123" -Complexity 8 | Should -Be "Tasklet Saved"
    }

    it "Get-Tasklet returns created tasklet" {
        (Get-Tasklet -PrioritySort -ComplexSort -Tags "Test").Title | Should -Be "Another Tasklet"
        (Get-Tasklet | where title -eq "Testing 123").Title | Should -Be "Testing 123"
    }

    it "Register-TaskletTouch allocates 50 to Priority when Read-Host is 3" {
        Mock Read-Host {return "3"}
        Mock Write-Host {}

        (Register-TaskletTouch)[0].Priority | Should -Be "50"
    }
    
    it "Register-TaskletTouch should filter down to only value/tag if asked" {
        Mock Read-Host {return "3"}
        Mock Write-Host {}

        (Register-TaskletTouch -Tags "Test").title | Should -Be "Another Tasklet"
    }
    
    it "Should archive the tasklet created above" {
        (Get-Tasklet | where title -eq "Testing 123") | Complete-Tasklet | Should -Be "Tasklet [Testing 123] Completed"
    }

    it "Should remove a tasklet with Remove-Tasklet" {
        (Get-Tasklet | where title -eq "Another Tasklet") | Remove-Tasklet | Should -Be  "Tasklet [Another Tasklet] Removed"
    }

    it "Should upload a new rewardlet" {
        New-Rewardlet -Title "More Testing" -Touch 3 -Taste 1 -Hear 8 -Smell 1 -Sight 13 -Time 8 | should -Be "Rewardlet Created"
        New-Rewardlet -Title "Testing Reward" -Touch 8 -Taste 1 -Hear 5 -Smell 3 -Sight 5 -Time 5 | should -Be "Rewardlet Created"
    }

    it "Should Add-Rewardlet to the transaction database" {
        Add-Rewardlet -Title "Testing Reward" | Should -Be "Rewardlet Registered as Taken"
    }

    it "Should be able to pull an available rewarlet" {
        $Rewardlet = Get-Rewardlet | Where Title -eq "Testing Reward"
        ($Rewardlet).Title | Should -Be "Testing Reward"
        ($Rewardlet).TaskRequirement | Should -Be 6

        $Rewardlet = Get-Rewardlet | Where Title -eq "More Testing"
        ($Rewardlet).Title | Should -Be "More Testing"
        ($Rewardlet).TaskRequirement | Should -Be 8
    }

    it "Should be able to pull a list of rewardlet transactions" {
        $Transaction = Get-RewardletTransaction | Where Title -eq "Testing Reward"
        $Transaction.TimeEstimate | should -Be 5
        $Transaction.DopamineIndex | should -Be 16
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
        (Get-LifeTracker).WillpowerToken | Should -Be -11
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
        $Transactions = Get-LifeTracker
        $Transactions.ChronoToken| Should -Be 16
        $Transactions.TaskToken | Should -Be 16
        $Transactions.WillpowerToken| Should -Be -7
    }

    it "Should Add-Journlet to the transaction database" {
        Add-Journlet -Title "Journal Entry" -Tags "Test,123" -WritingPrompt "This is a journal entry." | Should -Be "Journlet Registered as Taken"
    }

    it "Should be able to pull an available Journlet" {
        (Get-Journlet | Where Title -eq "Journal Entry").Title | Should -Be "Journal Entry"
    }

    it "Should Add-Countlet to the transaction database" {
        Add-Countlet -Title "Countlet Entry" -Tags "Test,123" | Should -Be "Countlet Registered as Taken"
    }

    it "Should be able to pull an available Countlet" {
        (Get-Countlet | Where Title -eq "Countlet Entry").Title | Should -Be "Countlet Entry"
    }

    it "Should show deviation metrics from Get-LifeTrackerAnalytics" {
        $Analytics = Get-LifeTrackerAnalytics
        $Analytics.TotalDiff | Should -Be -3.899
        $Analytics.WillpowerTokenDiff | Should -Be -3.328
        $Analytics.ChronoTokenDiff | Should -Be 0.062
        $Analytics.TaskTokenDiff | Should -Be -0.633
    }

    AfterAll {
        Remove-Item $script:DatabaseLocation -Force
    }
}