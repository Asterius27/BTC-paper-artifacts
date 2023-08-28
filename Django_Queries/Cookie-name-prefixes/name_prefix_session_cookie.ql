import python
import semmle.python.dataflow.new.DataFlow

// TODO intraprocedural version of the query
// TODO there might be other ways to change the session cookie name (not sure)
class NamePrefixConfiguration extends DataFlow::Configuration {
    NamePrefixConfiguration() { this = "NamePrefixConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr().(StrConst).getText().prefix(7) = "__Host-"
        or source.asExpr().(StrConst).getText().prefix(9) = "__Secure-"
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_COOKIE_NAME"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

where not exists(DataFlow::Node source, DataFlow::Node sink, NamePrefixConfiguration config | 
    config.hasFlow(source, sink))
select "Session cookie doesn't use either the __Host- or __Secure- prefixes"
