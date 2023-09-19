import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
predicate aux() {
    exists(DataFlow::Node sink, DataFlow::ExprNode source | 
        (sink = Flask::FlaskApp::instance().getMember("config").getSubscript("REMEMBER_COOKIE_SAMESITE").asSink()
        or sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("REMEMBER_COOKIE_SAMESITE").asSink())
        and source.asExpr().toString() != "None"
        and DataFlow::localFlow(source, sink))
}

predicate auxd() {
    exists(DataFlow::Node sink, KeyValuePair kv, DataFlow::ExprNode dsource | 
        sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).asSink()
        and kv = dsource.asExpr().(Dict).getAnItem()
        and kv.getKey().(Str).getText() = "REMEMBER_COOKIE_SAMESITE"
        and kv.getValue().toString() != "None"
        and DataFlow::localFlow(dsource, sink))
}

where not (aux() or auxd())
select "Remember cookie samesite attribute is disabled or not set (the default value is disabled)"
