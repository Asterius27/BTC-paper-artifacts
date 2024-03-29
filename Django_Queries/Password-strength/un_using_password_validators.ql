import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the password validators (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))

class PasswordValidatorsConfiguration extends DataFlow::Configuration {
    PasswordValidatorsConfiguration() { this = "PasswordValidatorsConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and (source.asExpr() instanceof List
            or source.asExpr() instanceof Tuple)
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "AUTH_PASSWORD_VALIDATORS"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, PasswordValidatorsConfiguration config
where config.hasFlow(source, sink)
    and (exists(source.asExpr().(List).getAnElt())
        or exists(source.asExpr().(Tuple).getAnElt()))
select source, sink, source.getLocation(), sink.getLocation(), "Using Django's password validation"
