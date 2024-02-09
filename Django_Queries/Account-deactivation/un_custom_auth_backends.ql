import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the password validators (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))
class AuthBackendsConfiguration extends DataFlow::Configuration {
    AuthBackendsConfiguration() { this = "AuthBackendsConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and source.asExpr() instanceof List
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "AUTHENTICATION_BACKENDS"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, AuthBackendsConfiguration config
where config.hasFlow(source, sink)
    and (not source.asExpr().(List).getAnElt().(StrConst).getS().prefix(29) = "django.contrib.auth.backends."
        or not exists(source.asExpr().(List).getAnElt().(StrConst).getS().prefix(29)))
select source, sink, source.getLocation(), sink.getLocation(), "Using a custom auth backend, so the app might allow deactivated accounts to log in"
