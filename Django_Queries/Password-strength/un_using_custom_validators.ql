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
        exists(AssignStmt asgn, AugAssign augasgn, Name name | 
            name.getId() = "AUTH_PASSWORD_VALIDATORS"
            and ((asgn.getATarget() = name
                and exists(asgn.getLocation().getFile().getRelativePath())
                and asgn.getValue().getAFlowNode() = sink.asCfgNode())
            or (augasgn.getTarget() = name
                and exists(augasgn.getLocation().getFile().getRelativePath())
                and augasgn.getValue().getAFlowNode() = sink.asCfgNode()))
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, PasswordValidatorsConfiguration config, KeyValuePair pair
where config.hasFlow(source, sink)
    and (pair = source.asExpr().(List).getAnElt().(Dict).getAnItem()
        or pair = source.asExpr().(Tuple).getAnElt().(Dict).getAnItem())
    and pair.getKey().(StrConst).getS() = "NAME"
    and (if exists(pair.getValue().(StrConst).getS().prefix(40))
        then pair.getValue().(StrConst).getS().prefix(40) != "django.contrib.auth.password_validation."
        else pair.getValue() instanceof Str)
select pair.getLocation(), source, sink, source.getLocation(), sink.getLocation(), "Using a custom password validator"
