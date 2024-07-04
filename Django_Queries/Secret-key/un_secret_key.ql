import python
import semmle.python.dataflow.new.DataFlow3
import semmle.python.dataflow.new.DataFlow2
import CodeQL_Library.DjangoSession

class SecretKeyConfiguration extends DataFlow2::Configuration {
    SecretKeyConfiguration() { this = "SecretKeyConfiguration" }

    override predicate isSource(DataFlow2::Node source) {
        source.asExpr() instanceof StrConst
    }

    override predicate isSink(DataFlow2::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SECRET_KEY"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

class ConfigValueConfiguration extends DataFlow3::Configuration {
    ConfigValueConfiguration() { this = "ConfigValueConfiguration" }

    override predicate isSource(DataFlow3::Node source) {
        DjangoSession::configSetFromEnvVar(source.asExpr())
    }

    override predicate isSink(DataFlow3::Node sink) {
        exists(AssignStmt asgn |
            exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

string output(StrConst key) {
    // minimum length recommended by the docs is 50
    if key.getS().length() < 50
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

string output2(StrConst key) {
    if key.getS().prefix(16) = "django-insecure-"
    then result = "The secret key was not freshly generated and is insecure (starts with django-insecure-)"
    else result = "The secret key was freshly generated (doesn't starts with django-insecure-)"
}

from StrConst str
where exists(DataFlow2::Node secsource, DataFlow2::Node key, SecretKeyConfiguration sconfig |
        sconfig.hasFlow(secsource, key)
        and (str = key.asExpr()
            or str = key.asExpr().getASubExpression())
        and not exists(DataFlow::Node env | 
            (env = API::moduleImport("os").getMember("getenv").getACall()
                or env = API::moduleImport("os").getMember("environ").getASubscript().getAValueReachableFromSource()
                or env = API::moduleImport("os").getMember("environ").getMember("get").getAValueReachableFromSource()
                or env = API::moduleImport("environs").getMember("Env").getReturn().getACall()
                or env = API::moduleImport("environs").getMember("Env").getReturn().getAMember().getACall())
            and exists(env.getLocation().getFile().getRelativePath())
            and (env.asExpr().(Call).getAPositionalArg() = str
                or env.asExpr().(Call).getANamedArg().(Keyword).getValue() = str)))
    or exists(Name name, AssignStmt asgn, DataFlow3::Node secsource, DataFlow3::Node key, ConfigValueConfiguration sconfig |
        sconfig.hasFlow(secsource, key)
        and name.getId() = "SECRET_KEY"
        and asgn.getATarget() = name
        and asgn.getValue().getAFlowNode() = key.asCfgNode()
        and (str = key.asExpr().(Call).getNamedArg(0).(Keyword).getValue().(StrConst)
            or str = key.asExpr().(Call).getPositionalArg(1).(StrConst)))
select str.getS(), str.getLocation(), output(str), output2(str)
