import python
import semmle.python.ApiGraphs

from DataFlow::Node n
where n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
  and n.asExpr().toString() = "None"
select n.getLocation(), "Session protection is disabled, there is no way to know if the cookies are stolen or not"