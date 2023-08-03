import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO use dataflow analysis (note: should already be interprocedural and should already take into account dataflow between variables, need to test it (in secret_key.ql it works))
// of course it doesn't detect values that are know only at runtime (such as environment variables)
from DataFlow::Node node
where node = Flask::FlaskApp::instance().getMember("config").getSubscript("REMEMBER_COOKIE_HTTPONLY").getAValueReachingSink()
    and node.asExpr().(ImmutableLiteral).booleanValue() = false
select node.getLocation(), "Remember cookie is accessible via javascript (HTTPOnly attribute set to false)"
