import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
where not exists(DataFlow::Node node | 
    node = Flask::FlaskApp::instance().getMember("config").getSubscript("SESSION_COOKIE_NAME").getAValueReachingSink()
    and (node.asExpr().(StrConst).getText().prefix(7) = "__Host-"
    or node.asExpr().(StrConst).getText().prefix(9) = "__Secure-"))
select "Session cookie doesn't use either the __Host- or __Secure- prefixes"
