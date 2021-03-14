class Base {
    [ValidateLength(5,50)]$Title
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
    [double]$Priority = 50
    [int]$Complexity
    $Value
    

    Tasklet ($Title,$Tags,$Complexity) {
        $this.title = $title
        $this.Tags = $Tags
        $this.Complexity = $Complexity
        $this._id = (New-Guid).guid
        $this.UpdatedOn = (Get-Date).Ticks
    }

    Tasklet ($Document) {
        $this.Title = $Document.Title
        $this._id = $Document._id
        $this.Complexity = $Document.Complexity
        $this.Value = $Document.value
        $this.Priority = $Document.Priority
        $this.Tags = $Document.Tags
        $this.UpdatedOn = (Get-Date).Ticks
    }
}

class Rewardlet : Base {
    $TimeEstimate
    $DopamineIndex
    $TaskRequirement

    Rewardlet ($Title,$TimeEstimate,$DopamineIndex,$TaskRequirement) {
        $this.Title = $Title
        $this.TimeEstimate = $TimeEstimate
        $this.DopamineIndex = $DopamineIndex
        $this.TaskRequirement = $TaskRequirement
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

class Countlet : Base {
    Countlet ($Title,$Tags) {
        $this.Title = $Title
        $this.Tags = $Tags
    }
}