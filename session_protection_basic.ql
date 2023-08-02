import python
import semmle.python.ApiGraphs

from DataFlow::Node n
where ((n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
  and n.asExpr().(StrConst).getText() = "basic")
  or not exists(API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()))
  and not exists(ControlFlowNode cfn | 
    cfn = API::moduleImport("flask_login").getMember("fresh_login_required").getACall().asCfgNode())
select "Session protection is enabled, but no @fresh_login_required found"