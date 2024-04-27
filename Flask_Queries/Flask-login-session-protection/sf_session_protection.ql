import python
import semmle.python.ApiGraphs

from DataFlow::Node n
where (n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
    or n = API::moduleImport("flask_login").getMember("login_manager").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())
  and n.asExpr().toString() = "None"
select n.getLocation(), "Session protection is manually disabled, there is no way to know if the cookies are stolen or not"