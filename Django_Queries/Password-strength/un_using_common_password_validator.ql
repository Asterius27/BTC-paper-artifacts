import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the password validators (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))
// TODO refine this query
class PasswordValidatorsConfiguration extends DataFlow::Configuration {
    PasswordValidatorsConfiguration() { this = "PasswordValidatorsConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and source.asExpr() instanceof List
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

from DataFlow::Node source, DataFlow::Node sink, PasswordValidatorsConfiguration config, KeyValuePair pair
where config.hasFlow(source, sink)
    and pair = source.asExpr().(List).getAnElt().(Dict).getAnItem()
    and pair.getKey().(StrConst).getS() = "NAME"
    and pair.getValue().(StrConst).getS() = "django.contrib.auth.password_validation.CommonPasswordValidator"
select pair.getLocation(), source, sink, source.getLocation(), sink.getLocation(), "Using a common password validator"
