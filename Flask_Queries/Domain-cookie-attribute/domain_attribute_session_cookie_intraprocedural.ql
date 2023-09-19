import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO define what "too permissive" is
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
DataFlow::Node aux() {
    exists(DataFlow::Node sink, DataFlow::ExprNode source | 
        (sink = Flask::FlaskApp::instance().getMember("config").getSubscript("SESSION_COOKIE_DOMAIN").asSink()
        or sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("SESSION_COOKIE_DOMAIN").asSink())
        and source.asExpr().toString() != "None"
        and DataFlow::localFlow(source, sink)
        and result = sink)
}

DataFlow::Node auxd() {
    exists(DataFlow::Node sink, KeyValuePair kv, DataFlow::ExprNode dsource | 
        sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).asSink()
        and kv = dsource.asExpr().(Dict).getAnItem()
        and kv.getKey().(Str).getText() = "SESSION_COOKIE_DOMAIN"
        and kv.getValue().toString() != "None"
        and DataFlow::localFlow(dsource, sink)
        and result = sink)
}

from DataFlow::Node node
where node = aux() or node = auxd()
select node.getLocation(), "Session cookie domain attribute is set"
