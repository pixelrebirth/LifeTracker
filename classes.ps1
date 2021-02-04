class Tasklet {
    [ValidateLength(5,40)]$Title
    [int]$Weight = 50
    $Tags
    $Value
    [guid]$_id

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
        
        Open-LiteDBConnection "./tasklet.db"
        Add-LiteDBDocument -Document $BSON -Collection "tasklets"
        Close-LiteDBConnection
    }

    [void] UpdateDb ($Document) {
        Open-LiteDBConnection "./tasklet.db"
        $BSON = $Document | ConvertTo-LiteDbBSON | Update-LiteDBDocument -Collection "tasklets"
        Close-LiteDBConnection
    }
    
    [void] RemoveFromDb () {
        #remove $this.id
    }
}