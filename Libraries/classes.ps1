class Base {
    [ValidateLength(5,50)]$Title
    [guid]$_id = (New-Guid).guid
    [long]$CreatedOn
    [long]$UpdatedOn
    $Tags
    $DbPath = $script:DatabaseLocation

    [void] UpdateCollection ($Collection) {
        $this.UpdatedOn = (Get-Date).Ticks

        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Update-LiteDBDocument -Collection $Collection | Out-Null
        Close-LiteDBConnection
    }

    [void] RemoveFromCurrentCollection ($Collection) {
        Open-LiteDBConnection $this.DbPath
        Remove-LiteDbDocument -Collection $Collection -Id $($this._id.guid) | Out-Null
        Close-LiteDBConnection
    }

    [void] AddToCollection ($Collection)  {
        $this.UpdatedOn = (Get-Date).Ticks
        
        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection $Collection
        Close-LiteDBConnection
    }

    [void] MoveCollection ($CurrentCollection,$DestinationCollection) {
        $this.AddToCollection($DestinationCollection)
        $this.RemoveFromCurrentCollection($CurrentCollection)
    }
}

class Tasklet : Base {
    [double]$Priority = 50
    [int]$Complexity
    $RelatedTo
    
    Tasklet ($Title,$Tags,$Complexity) {
        $this.title = $title
        $this.Tags = $Tags
        $this.Complexity = $Complexity
        $this._id = (New-Guid).guid
    }

    Tasklet ($Document) {
        $this.Title = $Document.Title
        $this._id = $Document._id
        $this.Complexity = $Document.Complexity
        $this.Priority = $Document.Priority
        $this.Tags = $Document.Tags
        $this.RelatedTo = $Document.RelatedTo
        $this.CreatedOn = $Document.CreatedOn
        $this.UpdatedOn = $Document.UpdatedOn
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