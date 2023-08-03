import python
import semmle.python.ApiGraphs

// TODO doesn't work if the value ("basic") isn't a string constant (so for example if it depends on environment variables (or any variable in general) or if it's the result of a function)
// possible solution: use dataflow analysis
from DataFlow::Node n
where ((n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
  and n.asExpr().(StrConst).getText() = "basic")
  or not exists(API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()))
  and not exists(ControlFlowNode cfn | 
    cfn = API::moduleImport("flask_login").getMember("fresh_login_required").getACall().asCfgNode())
select "Session protection is enabled, but no @fresh_login_required found"