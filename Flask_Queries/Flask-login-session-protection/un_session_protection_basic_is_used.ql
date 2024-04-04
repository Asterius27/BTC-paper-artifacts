import python
import semmle.python.ApiGraphs

from DataFlow::Node n
where (((n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
    or n = API::moduleImport("flask_login").getMember("login_manager").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())
  and n.asExpr().(StrConst).getText() = "basic")
  or (not exists(API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())
    and not exists(API::moduleImport("flask_login").getMember("login_manager").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())))
  and exists(ControlFlowNode cfn | 
    (cfn = API::moduleImport("flask_login").getMember("fresh_login_required").getAValueReachableFromSource().asCfgNode()
      or cfn = API::moduleImport("flask_login").getMember("utils").getMember("fresh_login_required").getAValueReachableFromSource().asCfgNode())
    and not cfn.isImportMember())
select "Session protection is enabled (in basic mode)"
