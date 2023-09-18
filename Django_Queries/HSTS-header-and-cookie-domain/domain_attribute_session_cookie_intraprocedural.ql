import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to set the Domain cookie attribute (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
from DataFlow::ExprNode source, DataFlow::ExprNode sink
where source.asExpr().toString() != "None"
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SESSION_COOKIE_DOMAIN"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
    and DataFlow::localFlow(source, sink)
select sink.getLocation(), "Session cookie domain attribute is set"
