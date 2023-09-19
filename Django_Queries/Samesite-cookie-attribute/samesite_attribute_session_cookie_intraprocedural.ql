import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the session cookie name (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
where exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
    (source.asExpr().(StrConst).getText() = "None"
    or source.asExpr().(ImmutableLiteral).booleanValue() = false)
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SESSION_COOKIE_SAMESITE"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
    and DataFlow::localFlow(source, sink))
select "Samesite attribute not set"
