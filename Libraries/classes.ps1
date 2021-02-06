class Tasklet {
    [ValidateLength(5,40)]$Title
    [double]$Weight = 50
    $Tags
    $Value
    [guid]$_id
    $DbPath = "$global:LifeTrackerModulePath/tasklet.db"

    Tasklet ($title,$value) {
        $this.title = $title
        $this.Value = $value
        $this._id = (new-guid).guid
    }

    Tasklet ($Document) {
        $this.Title = $Document.Title
        $this._id = $Document._id
        $this.Value = $Document.value
        $this.Weight = $Document.Weight
        $this.Tags = $Document.Tags
    }

    [void] AddToDb () {
        $BSON = $this | ConvertTo-LiteDbBSON
        
        Open-LiteDBConnection $this.DbPath
        Add-LiteDBDocument -Document $BSON -Collection "tasklets"
        Close-LiteDBConnection
    }

    [void] UpdateDb () {
        Open-LiteDBConnection $this.DbPath
        $BSON = $this | ConvertTo-LiteDbBSON | Update-LiteDBDocument -Collection "tasklets"
        Close-LiteDBConnection
    }
    
    [void] RemoveFromDb () {
        #remove $this.id
    }
}