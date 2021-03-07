class Base {
    [ValidateLength(5,40)]$Title
    [guid]$_id = (New-Guid).guid
    [long]$CreatedOn = (Get-Date).Ticks
    [long]$UpdatedOn
    $Tags
    $DbPath = $script:DatabaseLocation


    [void] UpdateCollection ($Collection) {
        $this.UpdatedOn = (Get-Date).Ticks

        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Update-LiteDBDocument -Collection $Collection | Out-Null
        Close-LiteDBConnection
    }

    [void] RemoveFromCurrentCollection () {
        $this.UpdatedOn = (Get-Date).Ticks

        Open-LiteDBConnection $this.DbPath
        Remove-LiteDbDocument -Collection "$($this.gettype().name)" -Id $($this._id.guid) | Out-Null
        Close-LiteDBConnection
    }

    [void] AddToCollection ($Collection)  {
        $this.UpdatedOn = (Get-Date).Ticks
        
        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection $Collection
        Close-LiteDBConnection
    }

    [void] MoveToCollection ($Collection) {
        $this.AddToCollection($Collection)
        $this.RemoveFromCurrentCollection()
    }
}

class Tasklet : Base {
    [double]$Weight = 50
    $Value
    

    Tasklet ($Title,$Tags) {
        $this.title = $title
        $this.Tags = $Tags
        $this._id = (New-Guid).guid
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
    $TaskRequirement = 50

    Rewardlet ($Title,$TimeEstimate,$DopamineIndex) {
        $this.Title = $Title
        $this.TimeEstimate = $TimeEstimate
        $this.DopamineIndex = $DopamineIndex
    }

    Rewardlet ($Document) {
        $this.Title = $Document.Title
        $this._id = $Document._id
        $this.UpdatedOn = (Get-Date).Ticks
        $this.TimeEstimate = $Document.TimeEstimate
        $this.DopamineIndex = $Document.DopamineIndex
        $this.TaskRequirement = $Document.TaskRequirement
    }
}

class Journlet : Base {
    $Body

    Journlet ($Title,$Tags) {
        $this.Title = $Title
        $this.Tags = $Tags
    }
}

class Habitlet : Base {
    Habitlet ($Title,$Tags) {
        $this.Title = $Title
        $this.Tags = $Tags
    }
    Habitlet ($Document) {
        $this.Title = $Document.Title
        $this.Tags = $Document.Tags
    }
}

class Timelet : Base {
    Timelet ($Title,$Tags) {
        $this.Title = $Title
        $this.Tags = $Tags
    }
    Timelet ($Document) {
        $this.Title = $Document.Title
        $this.Tags = $Document.Tags
    }
}