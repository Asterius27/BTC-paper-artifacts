import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
predicate aux() {
    exists(DataFlow::Node sink, DataFlow::ExprNode source | 
        (sink = Flask::FlaskApp::instance().getMember("config").getSubscript("SESSION_COOKIE_NAME").asSink()
        or sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("SESSION_COOKIE_NAME").asSink())
        and (source.asExpr().(StrConst).getText().prefix(7) = "__Host-"
        or source.asExpr().(StrConst).getText().prefix(9) = "__Secure-")
        and DataFlow::localFlow(source, sink))
}

predicate auxd() {
    exists(DataFlow::Node sink, KeyValuePair kv, DataFlow::ExprNode dsource | 
        sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).asSink()
        and kv = dsource.asExpr().(Dict).getAnItem()
        and kv.getKey().(Str).getText() = "SESSION_COOKIE_NAME"
        and (kv.getValue().(StrConst).getText().prefix(7) = "__Host-"
        or kv.getValue().(StrConst).getText().prefix(9) = "__Secure-")
        and DataFlow::localFlow(dsource, sink))
}

where not (aux() or auxd())
select "Session cookie doesn't use either the __Host- or __Secure- prefixes"
