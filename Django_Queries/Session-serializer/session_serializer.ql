import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the session cookie name (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
class SamesiteConfiguration extends DataFlow::Configuration {
    SamesiteConfiguration() { this = "SamesiteConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr().(StrConst).getText() != "django.contrib.sessions.serializers.JSONSerializer"
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_SERIALIZER"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

string output(DataFlow::Node source) {
    if source.asExpr().(StrConst).getText() = "django.contrib.sessions.serializers.PickleSerializer"
    then result = "Using pickle serializer that is unsafe"
    else result = "Using a custom serializer"
}

from DataFlow::Node source, DataFlow::Node sink, SamesiteConfiguration config
where config.hasFlow(source, sink)
select output(source)
