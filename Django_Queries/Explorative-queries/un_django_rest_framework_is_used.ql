import python
import semmle.python.ApiGraphs

// This library has login/logout ecc. built in
class InstalledAppsConfiguration extends DataFlow::Configuration {
    InstalledAppsConfiguration() { this = "InstalledAppsConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and (source.asExpr() instanceof List
            or source.asExpr() instanceof Tuple)
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "INSTALLED_APPS"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, InstalledAppsConfiguration config
where config.hasFlow(source, sink)
    and (source.asExpr().(List).getAnElt().(StrConst).getText() = "rest_framework"
        or source.asExpr().(Tuple).getAnElt().(StrConst).getText() = "rest_framework")
select source, source.getLocation(), "django rest framework is being used by the application"
