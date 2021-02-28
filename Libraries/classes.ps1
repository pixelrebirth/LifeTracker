class Base {
    [ValidateLength(5,40)]$Title
    [guid]$_id = (New-Guid).guid
    $DbPath = $script:DatabaseLocation
    [long]$CreatedOn = (Get-Date).Ticks
    [long]$UpdatedOn

    [void] AddToDb () {
        $this.UpdatedOn = (Get-Date).Ticks
        $BSON = $this | ConvertTo-LiteDbBSON
        
        Open-LiteDBConnection $this.DbPath
        Add-LiteDBDocument -Document $BSON -Collection "$($this.gettype().name)"
        Close-LiteDBConnection
    }

    [void] UpdateDb () {
        $this.UpdatedOn = (Get-Date).Ticks
        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Update-LiteDBDocument -Collection "$($this.gettype().name)" | Out-Null
        Close-LiteDBConnection
    }

    [void] Archive () {
        Open-LiteDBConnection $this.DbPath
        $this | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection "$($this.gettype().name)_archive"
        Remove-LiteDbDocument -Collection "$($this.gettype().name)" -Id $($this._id.guid) | Out-Null
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