import python
import semmle.python.dataflow.new.DataFlow

class SessionEngineConfiguration extends DataFlow::Configuration {
    SessionEngineConfiguration() { this = "SessionEngineConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr().(StrConst).getText().prefix(33) != "django.contrib.sessions.backends."
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_ENGINE"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, SessionEngineConfiguration config
where config.hasFlow(source, sink)
select source, sink, source.getLocation(), sink.getLocation(), "Using a custom session engine"
