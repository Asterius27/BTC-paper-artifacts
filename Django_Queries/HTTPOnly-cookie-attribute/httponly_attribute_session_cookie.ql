import python
import semmle.python.dataflow.new.DataFlow

// TODO intraprocedural version of the query
class HTTPOnlyConfiguration extends DataFlow::Configuration {
    HTTPOnlyConfiguration() { this = "HTTPOnlyConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof ImmutableLiteral
        and source.asExpr().(ImmutableLiteral).booleanValue() = false
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_COOKIE_HTTPONLY"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, HTTPOnlyConfiguration config
where config.hasFlow(source, sink)
select source.getLocation(), sink.getLocation(), "Session cookie is accessible via javascript (HTTPOnly attribute set to false)"

/* This works (not interprocedural nor intraprocedural)
from AssignStmt asgn, Name name
where name.getId() = "SESSION_COOKIE_HTTPONLY"
    and asgn.getATarget() = name
    and asgn.getValue().(ImmutableLiteral).booleanValue() = false
    and exists(asgn.getLocation().getFile().getRelativePath())
select asgn.getLocation(), "Session cookie is accessible via javascript (HTTPOnly attribute set to false)"
*/
