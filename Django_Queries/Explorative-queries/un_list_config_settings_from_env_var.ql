import python
import CodeQL_Library.DjangoSession

// TODO see if there are other ways to set config variables from env, in general have a look at the results to see what the developers are doing

class ConfigValueConfiguration extends DataFlow::Configuration {
    ConfigValueConfiguration() { this = "ConfigValueConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        DjangoSession::configSetFromEnvVar(source.asExpr())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn |
            exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

bindingset[configsetting, queryname]
string aux(string configsetting, string queryname) {
    exists(Name name, AssignStmt asgn, DataFlow::Node source, DataFlow::Node sink, ConfigValueConfiguration config |
        config.hasFlow(source, sink)
        and name.getId() = configsetting
        and asgn.getATarget() = name
        and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        and result = queryname + " " + source.getLocation())
}

string output() {
    result = aux("SECRET_KEY", "un_secret_key")
    or result = aux("SESSION_SERIALIZER", "un_session_serializer")
    or result = aux("AUTH_PASSWORD_VALIDATORS", "un_using_password_validators")
    or result = aux("PASSWORD_HASHERS", "un_manually_set_password_hashers")
    or result = aux("AUTHENTICATION_BACKENDS", "un_custom_auth_backends")
    or result = aux("SESSION_ENGINE", "custom_session_engine")
}

select output()
