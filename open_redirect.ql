import python
import semmle.python.security.dataflow.UrlRedirectQuery
import DataFlow::PathGraph

// TODO doesn't work if there is a function call in the guard (the if before the redirect), 
// only works if the variable is explicitly checked inside the if (with a == or others)
// source: https://github.com/github/codeql/blob/main/python/ql/src/Security/CWE-601/UrlRedirect.ql
from Configuration config, DataFlow::PathNode source, DataFlow::PathNode sink, Call login_call, Name name
where config.hasFlowPath(source, sink)
  and name.getId() = "login_user" 
  and login_call.getFunc() = name
  and login_call.getAFlowNode().getBasicBlock().reaches(sink.getNode().asCfgNode().getBasicBlock())
  /* TODO delete it (keeping it for now as an example)
  and exists(Call login_call, Name name |
    (name.getId() = "login_user" 
    and login_call.getFunc() = name)
    // and DataFlow::localFlow(DataFlow::exprNode(login_call), DataFlow::exprNode(sink.getNode().asExpr()))
    and login_call.getAFlowNode().getBasicBlock().reaches(sink.getNode().asCfgNode().getBasicBlock()))
  */
select sink.getNode(), source, sink, "Untrusted URL redirection after login depends on a $@.", source.getNode(), "user-provided value",
  login_call, login_call.getLocation()