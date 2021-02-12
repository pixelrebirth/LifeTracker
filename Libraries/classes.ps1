class Tasklet {
    [ValidateLength(5,40)]$Title
    [double]$Weight = 50
    $Tags
    $Value
    [guid]$_id
    $DbPath = $global:DatabaseLocation
    [long]$CreatedOn = (Get-Date).Ticks
    [long]$UpdatedOn

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

    [void] AddToDb () {
        $this.UpdatedOn = (Get-Date).Ticks
        $BSON = $this | ConvertTo-LiteDbBSON
        
        Open-LiteDBConnection $this.DbPath
        Add-LiteDBDocument -Document $BSON -Collection "tasklets"
        Close-LiteDBConnection
    }

    [void] UpdateDb () {
        $this.UpdatedOn = (Get-Date).Ticks
        Open-LiteDBConnection $this.DbPath
        $BSON = $this | ConvertTo-LiteDbBSON | Update-LiteDBDocument -Collection "tasklets"
        Close-LiteDBConnection
    }
}

class Rewardlet {
    [ValidateLength(5,40)]$Title
    [int]$Cost
    $Type

    Rewardlet ($Title,$Cost,$Type) {
        $this.Title = $Title
        $this.Cost = $Cost
        $this.Type = $Type
    }
    
    [void] SubmitReward () {
        $this.UpdatedOn = (Get-Date).Ticks
        $BSON = $this | ConvertTo-LiteDbBSON
        
        Open-LiteDBConnection $this.DbPath
        Add-LiteDBDocument -Document $BSON -Collection "rewardlets"
        Close-LiteDBConnection
    }
}

