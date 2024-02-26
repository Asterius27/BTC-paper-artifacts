import python
import CodeQL_Library.DjangoSession

// TODO finish it and see if there are other ways to set config variables from env, in general have a look at the results to see what the developers are doing

class ConfigValueConfiguration extends DataFlow::Configuration {
    ConfigValueConfiguration() { this = "ConfigValueConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        DjangoSession::configSetFromEnvVar(source.asExpr())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SECRET_KEY" // TODO find a way to pass this as a variable
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

string auxsk(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SECRET_KEY", "secret_key"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SECRET_KEY", "secret_key")
        and result = "un_secret_key " + node.getLocation()
    else none()
}

string auxrcss(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SAMESITE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SAMESITE")
        and result = "st_samesite_attribute_remember_cookie " + node.getLocation()
    else none()
}

string aux(Expr node) {
    result = auxsk(node)
    or result = auxrcss(node)
}

from Expr node
select aux(node)
