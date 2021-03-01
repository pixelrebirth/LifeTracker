class Base {
    [ValidateLength(5,40)]$Title
    [guid]$_id = (New-Guid).guid
    $DbPath = $script:DatabaseLocation
    [long]$CreatedOn = (Get-Date).Ticks
    [long]$UpdatedOn

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
    $Tags
    $Value
    

    Tasklet ($Title,$Value) {
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

    Rewardlet ($Document) {
        $this.Title = $Document.Title
        $this._id = (new-guid).guid
        $this.UpdatedOn = (Get-Date).Ticks
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