import python
import semmle.python.dataflow.new.DataFlow

// TODO intraprocedural version of the query
// TODO there might be other ways to set the Secure cookie attribute (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
class SecureConfiguration extends DataFlow::Configuration {
    SecureConfiguration() { this = "SecureConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof ImmutableLiteral
        and source.asExpr().(ImmutableLiteral).booleanValue() = true
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_COOKIE_SECURE"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

where not exists(DataFlow::Node source, DataFlow::Node sink, SecureConfiguration config | 
    config.hasFlow(source, sink))
select "Session cookie is also sent over HTTP (Secure attribute not set or set to false)"
