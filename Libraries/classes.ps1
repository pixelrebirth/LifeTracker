class Base {
    [guid]$_id
    $DbPath = $global:DatabaseLocation
    [long]$CreatedOn = (Get-Date).Ticks
    [long]$UpdatedOn

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
    [ValidateLength(5,40)]$Title
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
    [ValidateLength(5,40)]$Title
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
    [ValidateLength(5,40)]$Title
    $Body

    Journlet ($Title,$Body) {
        $this.Title = $Title
        $this.Body = $Body
    }
}

class Habitlet : Base {
    [ValidateLength(5,40)]$Title
    $Body

    Habitlet ($Title,$Body) {
        $this.Title = $Title
        $this.Body = $Body
    }
}

class Timelet : Base {
    [ValidateLength(5,40)]$Title
    $Body

    Timelet ($Title,$Body) {
        $this.Title = $Title
        $this.Body = $Body
    }
}