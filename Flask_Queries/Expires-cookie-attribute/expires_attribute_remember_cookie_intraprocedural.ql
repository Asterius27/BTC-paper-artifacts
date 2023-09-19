import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// This was slow (11 and a half minutes on toy application), the problem was with the ORs. Substituting them with an if solved the issue
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
bindingset[param]
int auxk(API::Node td, string param) {
    if exists(td.getKeywordParameter(param).asSink())
    then exists(DataFlow::Node num |
        DataFlow::localFlow(num, td.getKeywordParameter(param).asSink())
        and result = num.asExpr().(IntegerLiteral).getValue())
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
    if exists(td.getParameter(pos).asSink())
    then exists(DataFlow::Node num |
        DataFlow::localFlow(num, td.getParameter(pos).asSink())
        and result = num.asExpr().(IntegerLiteral).getValue())
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
        and DataFlow::localFlow(timedelta.getReturn().asSource(), config)
        and params(timedelta) + keywords(timedelta) < 2592000)
}

predicate expires_duration_kv(KeyValuePair kv) {
    if kv.getValue() instanceof IntegerLiteral
    then kv.getValue().(IntegerLiteral).getValue() < 2592000
    else exists(API::Node timedelta | 
        timedelta = API::moduleImport("datetime").getMember("timedelta")
        and DataFlow::localFlow(timedelta.getReturn().asSource(), DataFlow::exprNode(kv.getValue()))
        and params(timedelta) + keywords(timedelta) < 2592000)
}

predicate aux() {
    exists(DataFlow::Node sink, DataFlow::ExprNode source | 
        (sink = Flask::FlaskApp::instance().getMember("config").getSubscript("REMEMBER_COOKIE_DURATION").asSink()
        or sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("REMEMBER_COOKIE_DURATION").asSink())
        and expires_duration_node(source)
        and DataFlow::localFlow(source, sink))
}

predicate auxd() {
    exists(DataFlow::Node sink, KeyValuePair kv, DataFlow::ExprNode dsource | 
        sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).asSink()
        and kv = dsource.asExpr().(Dict).getAnItem()
        and kv.getKey().(Str).getText() = "REMEMBER_COOKIE_DURATION"
        and expires_duration_kv(kv)
        and DataFlow::localFlow(dsource, sink))
}

predicate auxdk() {
    exists(DataFlow::Node sink, DataFlow::ExprNode source | 
        (sink = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("duration").asSink()
        or sink = API::moduleImport("flask_login").getMember("login_user").getParameter(2).asSink())
        and expires_duration_node(source)
        and DataFlow::localFlow(source, sink))
}

where not (not exists(API::Node duration |
        duration = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("duration")
        or duration = API::moduleImport("flask_login").getMember("login_user").getParameter(2))
    and aux() or auxd())
    and not auxdk()
select "Remember cookie duration is too long"
