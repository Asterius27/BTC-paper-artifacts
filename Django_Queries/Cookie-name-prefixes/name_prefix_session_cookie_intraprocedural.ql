import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the session cookie name (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
where not exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
    (source.asExpr().(StrConst).getText().prefix(7) = "__Host-"
    or source.asExpr().(StrConst).getText().prefix(9) = "__Secure-")
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SESSION_COOKIE_NAME"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
    and DataFlow::localFlow(source, sink))
select "Session cookie doesn't use either the __Host- or __Secure- prefixes"

/* This works
from DataFlow::ExprNode source
where source.asExpr().(StrConst).getText().prefix(7) = "__Host-"
    or source.asExpr().(StrConst).getText().prefix(9) = "__Secure-"
select source, source.getLocation()
*/

/* This works
from DataFlow::ExprNode sink
where exists(AssignStmt asgn, Name name | 
        name.getId() = "SESSION_COOKIE_NAME"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
select sink, sink.getLocation()
*/
