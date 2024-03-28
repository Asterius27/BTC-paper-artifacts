import python
import semmle.python.ApiGraphs

class MiddlewareConfiguration extends DataFlow::Configuration {
    MiddlewareConfiguration() { this = "MiddlewareConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and source.asExpr() instanceof List
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "MIDDLEWARE"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, MiddlewareConfiguration config
where config.hasFlow(source, sink)
    and not source.asExpr().(List).getAnElt().(StrConst).getS() = "django.middleware.csrf.CsrfViewMiddleware"
select source, source.getLocation(), "Global CSRF protection is disabled"
