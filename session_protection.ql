import python
import semmle.python.ApiGraphs

// TODO use dataflow analysis (note: shoudl already be interprocedural and should already take into account dataflow between variables, need to test it (in secret_key_hardcoded.ql it works))
// of course it doesn't detect values that are know only at runtime (such as environment variables)
from DataFlow::Node n
where n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
  and n.asExpr().toString() = "None"
select n.getLocation(), "Session protection is disabled, there is no way to know if the cookies are stolen or not"