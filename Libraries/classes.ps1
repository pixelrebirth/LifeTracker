class Base {
    [ValidateLength(5,40)]$Title
    hidden [guid]$_id = (New-Guid).guid
    hidden $DbPath = $global:DatabaseLocation
    hidden [long]$CreatedOn = (Get-Date).Ticks
    hidden [long]$UpdatedOn

    [void] AddToDb () {
        $this.UpdatedOn = (Get-Date).Ticks
        $BSON = $this | ConvertTo-LiteDbBSON
        
        Open-LiteDBConnection $this.DbPath
        Add-LiteDBDocument -Document $BSON -Collection "$($this)s"
        Close-LiteDBConnection
    }

    [void] UpdateDb () {
        $this.UpdatedOn = (Get-Date).Ticks
        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Update-LiteDBDocument -Collection "$($this)s" | Out-Null
        Close-LiteDBConnection
    }

    [void] Archive () {
        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection "$($this)s_archive"
        Remove-LiteDbDocument -Collection "$($this)s" -Id $($this._id.guid) | Out-Null
        Close-LiteDBConnection
    }
}

class Tasklet : Base {
    [double]$Weight = 50
    $Tags
    $Value
    

    Tasklet ($title,$value) {
        $this.title = $title
        $this.Value = $value
        $this._id = (new-guid).guid
        $this.UpdatedOn = (Get-Date).Ticks
    }

    Tasklet ($Document) {
        $this.Title = $Document.Title
        $this._id = $Document._id
        $this.Value = $Document.value
        $this.Weight = $Document.Weight
        $this.Tags = $Document.Tags
        $this.UpdatedOn = (Get-Date).Ticks
    }
}

class Rewardlet : Base {
    [ValidateSet(1,2,3,5,8,13)]$TimeEstimate
    [ValidateSet(1,2,3,5,8,13)]$DopamineIndex
    $TaskRequirement = 100

    Rewardlet ($Title,$TimeEstimate,$DopamineIndex) {
        $this.Title = $Title
        $this.TimeEstimate = $TimeEstimate
        $this.DopamineIndex = $DopamineIndex
    }
}

class Journlet : Base {
    $Body

    Journlet ($Title,$Body) {
        $this.Title = $Title
        $this.Body = $Body
    }
}

class Habitlet : Base {
    $Body

    Habitlet ($Title,$Body) {
        $this.Title = $Title
        $this.Body = $Body
    }
}

class Timelet : Base {
    $Body

    Timelet ($Title,$Body) {
        $this.Title = $Title
        $this.Body = $Body
    }
}

class Character : Base {
    [ValidateLength(2,20)]$Name
    [int]$TaskTokens
    [int]$WillpowerTokens
    [int]$ChronoTokens
    [int]$BossTokens
    [int]$Dharma
    [ValidateSet('Character')]$BlobType

    Character ($Name) {
        $this.PopulateFromDb($Name)
    }
    
    Character () { 
        $this.PopulateFromDb("Alia.Stormchild")
    }

    [void] PopulateFromDb ($Name) {
        Open-LiteDBConnection $global:DatabaseLocation | Out-Null
        
        $CharacterDocument = Find-LiteDBDocument -Collection "blobs" | where BlobType -eq 'Character'
        if (!$CharacterDocument){
            $this.NewCharacter($Name)
            $CharacterDocument = Find-LiteDBDocument -Collection "blobs" | where BlobType -eq 'Character'
        }
        if ($CharacterDocument.count -ne 1){
            $CharacterDocument = $CharacterDocument | where Name -eq $Name
        }
    
        Close-LiteDBConnection | Out-Null

        $this.SetCharacter($CharacterDocument)
    }

    hidden [void] SetCharacter ($CharacterDocument) {
        $this.Name = $CharacterDocument.Name
        $this.Title = $CharacterDocument.Title
        $this.TaskTokens = $CharacterDocument.TaskTokens
        $this.WillpowerTokens = $CharacterDocument.WillpowerTokens
        $this.ChronoTokens = $CharacterDocument.ChronoTokens
        $this.BossTokens = $CharacterDocument.BossTokens
        $this.Dharma = $CharacterDocument.Dharma
    }

    [void] NewCharacter($Name) {
        $CharacterBase = @{
            Name=$Name
            TaskTokens=0
            WillpowerTokens=0
            ChronoTokens=0
            BossTokens=0
            Dharma=100
        } 
        
        $BSON = $CharacterBase | ConvertTo-LiteDbBSON
        Add-LiteDBDocument -Document $BSON -Collection "$($this)s"
    }
    [void] AddTaskToken() {}
}