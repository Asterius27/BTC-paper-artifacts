import python
import semmle.python.dataflow.new.DataFlow

// TODO intraprocedural version of the query
// TODO there might be other ways to set the Domain cookie attribute (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
class DomainConfiguration extends DataFlow::Configuration {
    DomainConfiguration() { this = "DomainConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr().toString() != "None"
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_COOKIE_DOMAIN"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, DomainConfiguration config
where config.hasFlow(source, sink)
select sink.getLocation(), "Session cookie domain attribute is set"
