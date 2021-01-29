class Tasklet {
    [ValidateLength(5,40)]$Title
    [ValidateSet(
        "Today",
        "Tomorrow",
        "This Week",
        "Next Week",
        "Next Month",
        "Next Quarter",
        "Next Year",
        "3 Years",
        "5 Years",
        "15  Years",
        "Someday",
        "Bucket List"
    )]$When
    
    [ValidateSet(
        "Once",
        "Scheduled",
        "OnComplete"    
    )]$Repeat

    [ValidateRange(1,5)]$Depth
    [ValidateLength(3,40)]$Value
    
    [ValidateSet(
        "New",
        "Active",
        "Done",
        "Archived"        
    )]$State

    [guid]$ParentId
    [guid]$Id
   
    $Config

    Tasklet ($title,$value) {
        $this.config = Get-Content ./config.json | ConvertFrom-Json

        $this.title = $title
        $this.Value = $value
        $this.id = (new-guid).guid
        $this.when = "This Week"
        $this.repeat = "Once"
        $this.depth = 1
        $this.state = "New"
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

    [void] AddParent($id) {

    }

    [void] RemoveParent($id) {

    } 
}