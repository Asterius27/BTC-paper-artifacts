import python
import semmle.python.ApiGraphs

// TODO doesn't work if the value ("None") isn't a literal (so for example if it depends on environment variables (or any variable in general) or if it's the result of a function)
// possible solution: use dataflow analysis
from DataFlow::Node n
where n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
  and n.asExpr().toString() = "None"
select n.getLocation(), "Session protection is disabled, there is no way to know if the cookies are stolen or not"