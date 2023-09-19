import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to set the Secure cookie attribute (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
where not exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
    (source.asExpr() instanceof ImmutableLiteral
    and source.asExpr().(ImmutableLiteral).booleanValue() = true)
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SESSION_COOKIE_SECURE"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
    and DataFlow::localFlow(source, sink))
select "Session cookie is also sent over HTTP (Secure attribute not set or set to false)"
