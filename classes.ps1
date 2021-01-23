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

    $Depth
    [guid]$ParentId
    [guid]$Id
    $Value
    $State

    Tasklet ($title,$value) {
        $this.title = $title
        $this.Value = $value
        $this.id = (new-guid).guid
        $this.when = "This Week"
        $this.repeat = "Once"
        $this.depth = 1
        $this.state = "New"
    }

    [void] AddToDb () {
        #connect to db and add $this to db
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