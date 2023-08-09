import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)

/*
from DataFlow::Node n
where n = API::moduleImport("flask").getMember("session").getMember("permanent").getAValueReachingSink()
    and n.asExpr().(ImmutableLiteral).booleanValue() = true
    and not exists(DataFlow::Node node | 
    node = Flask::FlaskApp::instance().getMember("config").getSubscript("PERMANENT_SESSION_LIFETIME").getAValueReachingSink()
    and node.asCfgNode().getAPredecessor() = n.asCfgNode()
    and node.asExpr() instanceof IntegerLiteral
    and node.asExpr().(IntegerLiteral).getValue() < 2592000) // 30 days
select "Remember cookie duration is too long"
*/

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

// TODO doesn't work if the parameter doesn't exist (have to check if it exists before adding them)
int keywords(API::Node td) {
    result = td.getKeywordParameter("weeks").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() * 604800
    // + td.getKeywordParameter("days").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() * 86400
    // + td.getKeywordParameter("seconds").getAValueReachingSink().asExpr().(IntegerLiteral).getValue()
    // + td.getKeywordParameter("microseconds").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() / 1000000
    // + td.getKeywordParameter("milliseconds").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() / 1000
    // + td.getKeywordParameter("minutes").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() * 60
    // + td.getKeywordParameter("hours").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() * 3600
}

from DataFlow::Node config, API::Node timedelta
where config = Flask::FlaskApp::instance().getMember("permanent_session_lifetime").getAValueReachingSink()
    and timedelta = API::moduleImport("datetime").getMember("timedelta")
    and config = timedelta.getReturn().getAValueReachableFromSource()
    // and keywords(timedelta) > 2592000
select keywords(timedelta), "Expires attribute is set and it's too long"
