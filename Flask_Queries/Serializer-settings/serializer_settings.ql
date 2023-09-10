import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
from DataFlow::Node node, KeyValuePair kv
where ((node = Flask::FlaskApp::instance().getMember("config").getSubscript("JSON_AS_ASCII").getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("JSON_AS_ASCII").getAValueReachingSink())
    and node.asExpr().(ImmutableLiteral).booleanValue() = false)
    or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
    and kv = node.asExpr().(Dict).getAnItem()
    and kv.getKey().(Str).getText() = "JSON_AS_ASCII"
    and kv.getValue().(ImmutableLiteral).booleanValue() = false)
select node.getLocation(), "Serialize objects to ASCII-encoded JSON is disabled, so the JSON will be returned as a Unicode string. This has security implications when rendering the JSON into JavaScript in templates."
