import python
import semmle.python.ApiGraphs

class PasswordRegexpConfiguration extends DataFlow::Configuration {
    PasswordRegexpConfiguration() { this = "PasswordRegexpConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and exists(DataFlow::Node form, AssignStmt asgn |
            form = API::moduleImport("django").getMember("forms").getMember("PasswordInput").getAValueReachableFromSource()
            and not form.asExpr() instanceof ImportMember
            and exists(form.asCfgNode())
            and exists(form.getLocation().getFile().getRelativePath())
            and asgn.getValue().contains(form.asExpr())
            and asgn.getATarget() = source.asExpr())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(DataFlow::Node re | 
            re = API::moduleImport("re").getAMember().getACall()
            and exists(re.getLocation().getFile().getRelativePath())
            and (re.asExpr().(Call).getAPositionalArg() = sink.asExpr()
                or re.asExpr().(Call).getANamedArg().(Keyword).getValue() = sink.asExpr())
        )
    }
}

class RegexpConfiguration extends DataFlow::Configuration {
    RegexpConfiguration() { this = "RegexpConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
        and source.asExpr() instanceof StrConst
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(DataFlow::Node re | 
            re = API::moduleImport("re").getAMember().getACall()
            and exists(re.getLocation().getFile().getRelativePath())
            and (re.asExpr().(Call).getPositionalArg(0) = sink.asExpr()
                or re.asExpr().(Call).getNamedArg(0).(Keyword).getValue() = sink.asExpr())
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, PasswordRegexpConfiguration config, DataFlow::Node re, DataFlow::Node resource, DataFlow::Node resink, RegexpConfiguration reconfig
where config.hasFlow(source, sink)
    and re = API::moduleImport("re").getAMember().getACall()
    and exists(re.getLocation().getFile().getRelativePath())
    and (re.asExpr().(Call).getAPositionalArg() = sink.asExpr()
        or re.asExpr().(Call).getANamedArg().(Keyword).getValue() = sink.asExpr())
    and (re.asExpr().(Call).getPositionalArg(0) = resink.asExpr()
        or re.asExpr().(Call).getNamedArg(0).(Keyword).getValue() = resink.asExpr())
    and reconfig.hasFlow(resource, resink)
select resink.asExpr().(StrConst).getS(), resink.getLocation(), "The password is manually checked against a regexp"
