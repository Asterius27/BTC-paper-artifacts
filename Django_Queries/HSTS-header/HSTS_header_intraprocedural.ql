import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to set the HSTS header (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
where not exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
    (source.asExpr() instanceof IntegerLiteral
    and source.asExpr().(IntegerLiteral).getValue() > 0)
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SECURE_HSTS_SECONDS"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
    and DataFlow::localFlow(source, sink))
select "HSTS not activated or misconfigured"
