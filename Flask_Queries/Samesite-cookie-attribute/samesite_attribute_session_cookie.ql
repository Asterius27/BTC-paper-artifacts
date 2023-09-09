import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
from DataFlow::Node node
where (node = Flask::FlaskApp::instance().getMember("config").getSubscript("SESSION_COOKIE_SAMESITE").getAValueReachingSink()
    and node.asExpr().toString() = "None")
    or not exists(Flask::FlaskApp::instance().getMember("config").getSubscript("SESSION_COOKIE_SAMESITE").getAValueReachingSink())
select "Session cookie samesite attribute is disable or not set (the default value is disabled)"
