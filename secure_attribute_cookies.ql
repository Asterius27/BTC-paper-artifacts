import python

// TODO might want to check if session cookies are disabled as part of the query
from AssignStmt asgn
where asgn.getValue().toString() = "False"
select asgn.getTarget(0), asgn.getLocation()
