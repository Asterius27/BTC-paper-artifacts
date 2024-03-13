import python
import semmle.python.ApiGraphs

// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
from DataFlow::Node n
where (((n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
    or n = API::moduleImport("flask_login").getMember("login_manager").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())
  and n.asExpr().(StrConst).getText() = "basic")
  or (not exists(API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())
    and not exists(API::moduleImport("flask_login").getMember("login_manager").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())))
  and not exists(ControlFlowNode cfn | 
    (cfn = API::moduleImport("flask_login").getMember("fresh_login_required").getAValueReachableFromSource().asCfgNode()
      or cfn = API::moduleImport("flask_login").getMember("utils").getMember("fresh_login_required").getAValueReachableFromSource().asCfgNode())
    and not cfn.isImportMember())
select "Session protection is enabled (in basic mode), but no @fresh_login_required found"