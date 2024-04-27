import python
import semmle.python.dataflow.new.DataFlow

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
    and (pair.getValue().(StrConst).getS() = "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"
        or pair.getValue().(BinaryExpr).getLeft().(StrConst).getS() + pair.getValue().(BinaryExpr).getRight().(StrConst).getS() = "django.contrib.auth.password_validation.UserAttributeSimilarityValidator")
select pair.getLocation(), source, sink, source.getLocation(), sink.getLocation(), "Using a password similarity (with username and other fields) validator"
