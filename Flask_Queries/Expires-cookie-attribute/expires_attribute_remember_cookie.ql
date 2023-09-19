import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// This was slow (11 and a half minutes on toy application), the problem was with the ORs. Substituting them with an if solved the issue
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
bindingset[param]
int auxk(API::Node td, string param) {
    if exists(td.getKeywordParameter(param).getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
    then result = td.getKeywordParameter(param).getAValueReachingSink().asExpr().(IntegerLiteral).getValue()
    else result = 0
}

int keywords(API::Node td) {
    result = auxk(td, "weeks") * 604800
    + auxk(td, "days") * 86400
    + auxk(td, "seconds")
    + auxk(td, "microseconds") / 1000000
    + auxk(td, "milliseconds") / 1000
    + auxk(td, "minutes") * 60
    + auxk(td, "hours") * 3600
}

bindingset[pos]
int auxp(API::Node td, int pos) {
    if exists(td.getParameter(pos).getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
    then result = td.getParameter(pos).getAValueReachingSink().asExpr().(IntegerLiteral).getValue()
    else result = 0
}

int params(API::Node td) {
    result = auxp(td, 0) * 86400
    + auxp(td, 1)
    + auxp(td, 2) / 1000000
    + auxp(td, 3) / 1000
    + auxp(td, 4) * 60
    + auxp(td, 5) * 3600
    + auxp(td, 6) * 604800
}

predicate expires_duration_node(DataFlow::Node config) {
    if config.asExpr() instanceof IntegerLiteral
    then config.asExpr().(IntegerLiteral).getValue() < 2592000 // 30 days
    else exists(API::Node timedelta | 
        timedelta = API::moduleImport("datetime").getMember("timedelta")
        and config = timedelta.getReturn().getAValueReachableFromSource()
        and params(timedelta) + keywords(timedelta) < 2592000)
}

predicate expires_duration_kv(KeyValuePair kv) {
    if kv.getValue() instanceof IntegerLiteral
    then kv.getValue().(IntegerLiteral).getValue() < 2592000
    else exists(API::Node timedelta | 
        timedelta = API::moduleImport("datetime").getMember("timedelta")
        and kv.getValue().getAFlowNode() = timedelta.getReturn().getAValueReachableFromSource().asCfgNode()
        and params(timedelta) + keywords(timedelta) < 2592000)
}

where not exists(DataFlow::Node config, KeyValuePair kv | 
        not exists(DataFlow::Node duration |
            duration = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("duration").getAValueReachingSink()
            or duration = API::moduleImport("flask_login").getMember("login_user").getParameter(2).getAValueReachingSink())
        and (((config = Flask::FlaskApp::instance().getMember("config").getSubscript("REMEMBER_COOKIE_DURATION").getAValueReachingSink()
        or config = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("REMEMBER_COOKIE_DURATION").getAValueReachingSink())
        and expires_duration_node(config))
        or (config = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
        and kv = config.asExpr().(Dict).getAnItem()
        and kv.getKey().(Str).getText() = "REMEMBER_COOKIE_DURATION"
        and expires_duration_kv(kv))))
    and not exists(DataFlow::Node config | 
        (config = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("duration").getAValueReachingSink()
        or config = API::moduleImport("flask_login").getMember("login_user").getParameter(2).getAValueReachingSink())
        and expires_duration_node(config))
select "Remember cookie duration is too long"

/* This works
from DataFlow::Node config, API::Node timedelta
where (config = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("duration").getAValueReachingSink()
    or config = API::moduleImport("flask_login").getMember("login_user").getParameter(2).getAValueReachingSink())
    and timedelta = API::moduleImport("datetime").getMember("timedelta")
    and config = timedelta.getReturn().getAValueReachableFromSource()
select params(timedelta) + keywords(timedelta)
*/
