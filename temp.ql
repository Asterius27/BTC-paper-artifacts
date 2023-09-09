import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
from DataFlow::Node node
where node = Flask::FlaskApp::instance().getMember("config").getSubscript("JSON_AS_ASCII").getAValueReachingSink()
    and node.asExpr().(ImmutableLiteral).booleanValue() = false
select node.getLocation(), "Serialize objects to ASCII-encoded JSON is disabled, so the JSON will be returned as a Unicode string. This has security implications when rendering the JSON into JavaScript in templates."
