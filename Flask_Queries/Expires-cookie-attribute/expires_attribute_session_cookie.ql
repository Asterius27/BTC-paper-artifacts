import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// TODO this is slow (3 and a half minutes on toy application)
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

where exists(DataFlow::Node perma | 
        perma = API::moduleImport("flask").getMember("session").getMember("permanent").getAValueReachingSink()
        and perma.asExpr().(ImmutableLiteral).booleanValue() = true
        and exists(perma.getLocation().getFile().getRelativePath()))
    and (exists(DataFlow::Node config, API::Node timedelta, KeyValuePair kv | 
        ((config = Flask::FlaskApp::instance().getMember("config").getSubscript("PERMANENT_SESSION_LIFETIME").getAValueReachingSink()
        or config = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("PERMANENT_SESSION_LIFETIME").getAValueReachingSink())
        and exists(config.getLocation().getFile().getRelativePath())
        and ((config.asExpr() instanceof IntegerLiteral
        and config.asExpr().(IntegerLiteral).getValue() > 2592000) // 30 days
        or (timedelta = API::moduleImport("datetime").getMember("timedelta")
        and exists(timedelta.getReturn().getAValueReachableFromSource().getLocation().getFile().getRelativePath())
        and config = timedelta.getReturn().getAValueReachableFromSource()
        and params(timedelta) + keywords(timedelta) > 2592000)))
        or (config = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
        and kv = config.asExpr().(Dict).getAnItem()
        and kv.getKey().(Str).getText() = "PERMANENT_SESSION_LIFETIME"
        and (kv.getValue().(IntegerLiteral).getValue() > 2592000
        or (timedelta = API::moduleImport("datetime").getMember("timedelta")
        and kv.getValue().getAFlowNode() = timedelta.getReturn().getAValueReachableFromSource().asCfgNode()
        and params(timedelta) + keywords(timedelta) > 2592000))))
    or exists(DataFlow::Node config, API::Node timedelta | 
        config = Flask::FlaskApp::instance().getMember("permanent_session_lifetime").getAValueReachingSink()
        and exists(config.getLocation().getFile().getRelativePath())
        and ((config.asExpr() instanceof IntegerLiteral
        and config.asExpr().(IntegerLiteral).getValue() > 2592000)
        or (timedelta = API::moduleImport("datetime").getMember("timedelta")
        and exists(timedelta.getReturn().getAValueReachableFromSource().getLocation().getFile().getRelativePath())
        and config = timedelta.getReturn().getAValueReachableFromSource()
        and params(timedelta) + keywords(timedelta) > 2592000))))
select "Session cookie duration is too long"

/* This works
from DataFlow::Node n
where n = API::moduleImport("flask").getMember("session").getMember("permanent").getAValueReachingSink()
    and n.asExpr().(ImmutableLiteral).booleanValue() = true
select n.getLocation()
*/

/* This works
from DataFlow::Node node
where node = Flask::FlaskApp::instance().getMember("config").getSubscript("PERMANENT_SESSION_LIFETIME").getAValueReachingSink()
select node.getLocation(), node.asExpr() // returns timedelta() (depends on how timedelta was imported)
*/

/* This works (when importing datetime and then doing datetime.timedelta(...) or when importing datetime as dt and then doing dt.timedelta(...) or when doing from datetime import timedelta and then doing timedelta(...))
from DataFlow::Node node
where node = API::moduleImport("datetime").getMember("timedelta").getReturn().getAValueReachableFromSource()
    and exists(node.getLocation().getFile().getRelativePath())
select node.getLocation(), node.asExpr() // returns timedelta() or Attribute() depending on how timedelta was imported (using from ... import ... returns timedelta())
*/

/* This works
from DataFlow::Node node
where node = Flask::FlaskApp::instance().getMember("permanent_session_lifetime").getAValueReachingSink()
select node.getLocation(), node.asExpr() // returns Attribute() (depends on how timedelta was imported)
*/

/* This works
from DataFlow::Node config, API::Node timedelta
where config = Flask::FlaskApp::instance().getMember("config").getSubscript("PERMANENT_SESSION_LIFETIME").getAValueReachingSink()
    and timedelta = API::moduleImport("datetime").getMember("timedelta")
    and config = timedelta.getReturn().getAValueReachableFromSource()
// select timedelta.getKeywordParameter("days").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() // This does not find normal parameters
select timedelta.getParameter(0).getAValueReachingSink().asExpr().(IntegerLiteral).getValue() // This does not find the keyword parameters
*/

/* This works
from DataFlow::Node config, API::Node timedelta
where config = Flask::FlaskApp::instance().getMember("permanent_session_lifetime").getAValueReachingSink()
    and timedelta = API::moduleImport("datetime").getMember("timedelta")
    and config = timedelta.getReturn().getAValueReachableFromSource()
select timedelta.getKeywordParameter("weeks").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() // This does not find normal parameters
// select timedelta.getParameter(0).getAValueReachingSink().asExpr().(IntegerLiteral).getValue() // This does not find the keyword parameters
*/

/* This works
from DataFlow::Node config, API::Node timedelta
where config = Flask::FlaskApp::instance().getMember("permanent_session_lifetime").getAValueReachingSink()
    and timedelta = API::moduleImport("datetime").getMember("timedelta")
    and config = timedelta.getReturn().getAValueReachableFromSource()
    and keywords(timedelta) > 2592000
select "Expires attribute is set and it's too long"
*/

/* This works
from DataFlow::Node config, API::Node timedelta
where config = Flask::FlaskApp::instance().getMember("config").getSubscript("PERMANENT_SESSION_LIFETIME").getAValueReachingSink()
    and timedelta = API::moduleImport("datetime").getMember("timedelta")
    and config = timedelta.getReturn().getAValueReachableFromSource()
    and params(timedelta) > 2592000
select "Expires attribute is set and it's too long"
*/
