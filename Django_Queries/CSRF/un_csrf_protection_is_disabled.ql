import python
import semmle.python.ApiGraphs

class MiddlewareConfiguration extends DataFlow::Configuration {
    MiddlewareConfiguration() { this = "MiddlewareConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and (source.asExpr() instanceof List
            or source.asExpr() instanceof Tuple)
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, AugAssign augasgn, Name name | 
            (name.getId() = "MIDDLEWARE"
                or name.getId() = "MIDDLEWARE_CLASSES")
            and ((asgn.getATarget() = name
                and exists(asgn.getLocation().getFile().getRelativePath())
                and asgn.getValue().getAFlowNode() = sink.asCfgNode())
            or (augasgn.getTarget() = name
                and exists(augasgn.getLocation().getFile().getRelativePath())
                and augasgn.getValue().getAFlowNode() = sink.asCfgNode()))
        )
    }
}

where not exists(DataFlow::Node source, DataFlow::Node sink, MiddlewareConfiguration config |
    config.hasFlow(source, sink)
    and (source.asExpr().(List).getAnElt().(StrConst).getS() = "django.middleware.csrf.CsrfViewMiddleware"
        or source.asExpr().(Tuple).getAnElt().(StrConst).getS() = "django.middleware.csrf.CsrfViewMiddleware"))
select "Global CSRF protection is disabled"
