import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the password validators (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))
// TODO refine this query
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

string output(Dict pr) {
    if pr.getAnItem().(KeyValuePair).getKey().(StrConst).getS() = "OPTIONS"
    then exists(KeyValuePair pair, KeyValuePair prnt |
        prnt = pr.getAnItem()
        and prnt.getKey().(StrConst).getS() = "OPTIONS"
        and pair = prnt.getValue().(Dict).getAnItem()
        and pair.getKey().(StrConst).getS() = "min_length"
        and result = "Min value manually set: " + pair.getValue().(IntegerLiteral).getValue().toString())
    else result = ""
}

from DataFlow::Node source, DataFlow::Node sink, PasswordValidatorsConfiguration config, KeyValuePair pair, Dict dct
where config.hasFlow(source, sink)
    and (dct = source.asExpr().(List).getAnElt().(Dict)
        or dct = source.asExpr().(Tuple).getAnElt().(Dict))
    and pair = dct.getAnItem()
    and pair.getKey().(StrConst).getS() = "NAME"
    and (pair.getValue().(StrConst).getS() = "django.contrib.auth.password_validation.MinimumLengthValidator"
        or pair.getValue().(BinaryExpr).getLeft().(StrConst).getS() + pair.getValue().(BinaryExpr).getRight().(StrConst).getS() = "django.contrib.auth.password_validation.MinimumLengthValidator")
select pair.getLocation(), source, sink, source.getLocation(), sink.getLocation(), output(dct), "Using a length password validator"
