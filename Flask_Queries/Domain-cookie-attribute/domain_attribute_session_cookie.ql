import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO define what "too permissive" is
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
from DataFlow::Node node, KeyValuePair kv
where ((node = Flask::FlaskApp::instance().getMember("config").getSubscript("SESSION_COOKIE_DOMAIN").getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("SESSION_COOKIE_DOMAIN").getAValueReachingSink())
    and node.asExpr().toString() != "None")
    or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
    and kv = node.asExpr().(Dict).getAnItem()
    and kv.getKey().(Str).getText() = "SESSION_COOKIE_DOMAIN"
    and kv.getValue().toString() != "None")
select node.getLocation(), "Session cookie domain attribute is set"
