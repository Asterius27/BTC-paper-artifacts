import python
import semmle.python.dataflow.new.DataFlow

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

where not exists(DataFlow::Node source, DataFlow::Node sink, HSTSConfiguration config | 
    config.hasFlow(source, sink))
select "HSTS not activated or misconfigured"
