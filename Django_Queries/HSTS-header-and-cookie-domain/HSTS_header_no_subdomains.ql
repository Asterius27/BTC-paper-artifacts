import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.DataFlow2

// TODO there might be other ways to set the HSTS header (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
class HSTSConfiguration extends DataFlow::Configuration {
    HSTSConfiguration() { this = "HSTSConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof IntegerLiteral
        and source.asExpr().(IntegerLiteral).getValue() > 0
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SECURE_HSTS_SECONDS"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

class HSTSSubdomainsConfiguration extends DataFlow2::Configuration {
    HSTSSubdomainsConfiguration() { this = "HSTSSubdomainsConfiguration" }

    override predicate isSource(DataFlow2::Node source) {
        source.asExpr() instanceof ImmutableLiteral
        and source.asExpr().(ImmutableLiteral).booleanValue() = true
    }

    override predicate isSink(DataFlow2::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SECURE_HSTS_INCLUDE_SUBDOMAINS"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

where exists(DataFlow::Node source, DataFlow::Node sink, HSTSConfiguration config | 
        config.hasFlow(source, sink))
    and not exists(DataFlow2::Node source, DataFlow2::Node sink, HSTSSubdomainsConfiguration config | 
        config.hasFlow(source, sink))
select "HSTS activated without the includeSubDomains option"
