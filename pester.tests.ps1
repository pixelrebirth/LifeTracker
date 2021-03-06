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
        New-Tasklet -Value "Leadership" -Title "Another Tasklet" -Tags "Test,123" | Should -Be "Tasklet Saved"
        New-Tasklet -Value "Systemic" -Title "Testing 123" -Tags "123" | Should -Be "Tasklet Saved"
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
        New-Rewardlet -Title "More Testing" -TimeEstimate 5 -DopamineIndex 1 | should -Be "Rewardlet Created"
        New-Rewardlet -Title "Testing Reward" -TimeEstimate 8 -DopamineIndex 3 | should -Be "Rewardlet Created"
    }

    it "Should Add-Rewardlet to the transaction database" {
        Add-Rewardlet -Title "Testing Reward" | Should -Be "Rewardlet Registered as Taken"
    }

    it "Should be able to pull an available rewarlet" {
        $Rewardlet = Get-Rewardlet | Where Title -eq "Testing Reward"
        ($Rewardlet).title | Should -Be "Testing Reward"
        ($Rewardlet).TaskRequirement | Should -Be 52.5

        $Rewardlet = Get-Rewardlet | Where Title -eq "More Testing"
        ($Rewardlet).title | Should -Be "More Testing"
        ($Rewardlet).TaskRequirement | Should -Be 47.5
    }

    it "Should be able to pull a list of rewardlet transactions" {
        $Transaction = Get-RewardletTransaction
        $Transaction[0].TimeEstimate | should -Be 8
        $Transaction[0].DopamineIndex | should -Be 3
        $Transaction[0].title | should -Be "Testing Reward"
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

    it "Should output a transaction log with Get-LifetrackerTransaction" {
        $Transactions = Get-LifeTracker
        ($Transactions.ChronoToken | Measure-Object -Sum).sum | Should -Be 2
        ($Transactions.TaskToken | Measure-Object -Sum).sum | Should -Be -2
        ($Transactions.WillpowerToken | Measure-Object -Sum).sum | Should -Be 4
    }

    AfterAll {
        Remove-Item $script:DatabaseLocation -Force
    }
}