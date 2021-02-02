class Tasklet {
    [ValidateLength(5,40)]$Title
    $Weight
    $Tags
    $Value
    [guid]$Id

    Tasklet ($title,$value) {
        $this.title = $title
        $this.Value = $value
        $this.id = (new-guid).guid
    }

    [void] AddToDb () {
        $BSON = $this | ConvertTo-LiteDbBSON
        
        Open-LiteDBConnection "./tasklet.db"
        Add-LiteDBDocument -Document $BSON -Collection "tasklets"
        Close-LiteDBConnection
    }

    [void] UpdateDb ($json) {

    }

    [void] PopulateFromDb ($id) {

    }
    
    [void] RemoveFromDb () {
        #remove $this.id
    }
}