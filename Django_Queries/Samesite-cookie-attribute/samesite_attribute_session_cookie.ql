import python
import semmle.python.dataflow.new.DataFlow

// TODO intraprocedural version of the query
// TODO there might be other ways to change the session cookie name (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
class SamesiteConfiguration extends DataFlow::Configuration {
    SamesiteConfiguration() { this = "SamesiteConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr().(StrConst).getText() = "None"
        or source.asExpr().(ImmutableLiteral).booleanValue() = false
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_COOKIE_SAMESITE"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

where exists(DataFlow::Node source, DataFlow::Node sink, SamesiteConfiguration config | 
    config.hasFlow(source, sink))
select "Samesite attribute not set"
