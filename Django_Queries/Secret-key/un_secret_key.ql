import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.DataFlow2

class SecretKeyConfiguration extends DataFlow2::Configuration {
    SecretKeyConfiguration() { this = "SecretKeyConfiguration" }

    override predicate isSource(DataFlow2::Node source) {
        source.asExpr() instanceof StrConst
    }

    override predicate isSink(DataFlow2::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SECRET_KEY"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

string output(StrConst key) {
    // minimum length recommended by the docs is 50
    if key.getS().length() < 50
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

string output2(StrConst key) {
    if key.getS().prefix(16) = "django-insecure-"
    then result = "The secret key was not freshly generated and is insecure (starts with django-insecure-)"
    else result = "The secret key was freshly generated (doesn't starts with django-insecure-)"
}

from DataFlow2::Node secsource, DataFlow2::Node key, SecretKeyConfiguration sconfig
where sconfig.hasFlow(secsource, key)
select key.asExpr().(StrConst).getS(), key.getLocation(), output(key.asExpr()), output2(key.asExpr())
