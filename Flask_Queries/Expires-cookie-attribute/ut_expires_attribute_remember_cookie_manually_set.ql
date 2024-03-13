import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

// TODO might want to check if session cookies are disabled as part of the query
// TODO fix moduleImport("flask_login").getMember("utils")
from Expr expr
where expr = FlaskLogin::getConfigValue("REMEMBER_COOKIE_DURATION")
    or exists(DataFlow::Node config | 
        (config = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("duration").getAValueReachingSink()
            or config = API::moduleImport("flask_login").getMember("login_user").getParameter(2).getAValueReachingSink())
        and expr = config.asExpr())
select expr, expr.getLocation(), "Remember cookie duration is manually set"
