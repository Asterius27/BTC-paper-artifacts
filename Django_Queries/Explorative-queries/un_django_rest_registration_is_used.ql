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
        exists(AssignStmt asgn, AugAssign augasgn, Name name | 
            name.getId() = "INSTALLED_APPS"
            and ((asgn.getATarget() = name
                and exists(asgn.getLocation().getFile().getRelativePath())
                and asgn.getValue().getAFlowNode() = sink.asCfgNode())
            or (augasgn.getTarget() = name
                and exists(augasgn.getLocation().getFile().getRelativePath())
                and augasgn.getValue().getAFlowNode() = sink.asCfgNode()))
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, InstalledAppsConfiguration config
where config.hasFlow(source, sink)
    and (source.asExpr().(List).getAnElt().(StrConst).getText() = "rest_registration"
        or source.asExpr().(Tuple).getAnElt().(StrConst).getText() = "rest_registration")
select source, source.getLocation(), "django rest registration is being used by the application"
