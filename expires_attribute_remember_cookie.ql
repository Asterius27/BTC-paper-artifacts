import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
where not exists(DataFlow::Node node | 
    node = Flask::FlaskApp::instance().getMember("config").getSubscript("REMEMBER_COOKIE_DURATION").getAValueReachingSink()
    and node.asExpr().(IntegerLiteral).getValue() < 2592000) // 30 days
    and not exists(DataFlow::Node node | 
    node = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("duration").getAValueReachingSink()
    and node.asExpr().(IntegerLiteral).getValue() < 2592000) // 30 days
select "Remember cookie duration is too long"
