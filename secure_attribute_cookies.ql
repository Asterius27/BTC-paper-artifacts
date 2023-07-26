import python

// TODO might want to check if session cookies are disabled as part of the query
// TODO complete it
from AssignStmt asgn, Name name
where 
    asgn.getValue().toString() = "False" and name.getId() = "app" and asgn.getTarget(0) = name
    // v.getId() = "app.config"
select 
    asgn.getTarget(0), asgn.getLocation()
    // v
