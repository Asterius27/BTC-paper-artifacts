import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
where not exists(DataFlow::Node node, KeyValuePair kv | 
    ((node = Flask::FlaskApp::instance().getMember("config").getSubscript("REMEMBER_COOKIE_NAME").getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("REMEMBER_COOKIE_NAME").getAValueReachingSink())
    and (node.asExpr().(StrConst).getText().prefix(7) = "__Host-"
    or node.asExpr().(StrConst).getText().prefix(9) = "__Secure-"))
    or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
    and kv = node.asExpr().(Dict).getAnItem()
    and kv.getKey().(Str).getText() = "REMEMBER_COOKIE_NAME"
    and (kv.getValue().(StrConst).getText().prefix(7) = "__Host-"
    or kv.getValue().(StrConst).getText().prefix(9) = "__Secure-")))
select "Remember cookie doesn't use either the __Host- or __Secure- prefixes"
