import python
import semmle.python.security.dataflow.UrlRedirectQuery
import DataFlow::PathGraph

// TODO doesn't work if there is a function call in the guard (the if before the redirect), 
// only works if the variable is explicitly checked inside the if (with a == or others)
// source: https://github.com/github/codeql/blob/main/python/ql/src/Security/CWE-601/UrlRedirect.ql

// TODO finish interprocedural flow analysis (between next variable and login_user)
// TODO sink might be before the login_user call

class LoginDataFlowConfiguration extends DataFlow::Configuration {
  LoginDataFlowConfiguration() { this = "LoginRedirect" }

  override predicate isSource(DataFlow::Node source) {
    /*exists(Call login_call, Name name | 
      name.getId() = "login_user" 
      and login_call.getFunc() = name
      and source.asExpr() = login_call)*/
    // or source instanceof Source
    // source.asExpr().toString() = "next"
    exists(Name name |
      name.getId() = "next"
      and source.asExpr() = name)
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(Call login_call, Name name | 
      name.getId() = "login_user" 
      and login_call.getFunc() = name
      and sink.asExpr() = login_call)
    // sink instanceof Sink
    // sink instanceof DataFlow::Node
    /*exists(Name name |
      name.getId() = "next"
      and sink.asExpr() = name)*/
    // sink.asExpr().toString() = "next"
  }
}

from Configuration config, LoginDataFlowConfiguration lconfig, DataFlow::PathNode source, DataFlow::PathNode sink, 
  DataFlow::PathNode login_call, DataFlow::Node sink2
where
  config.hasFlowPath(source, sink)
  // lconfig.hasFlow(sink2, login_call)
  // or lconfig.hasFlow(sink.getNode(), login_call))
select sink.getNode(), source, sink, "Untrusted URL redirection after login depends on a $@.", source.getNode(), "user-provided value",
  login_call, login_call.getNode().getLocation(), sink.getNode().getLocation(), sink.getNode().asExpr(), source.getNode().getLocation(), source.getNode().asExpr()

/* Not interprocedural
from Configuration config, DataFlow::PathNode source, DataFlow::PathNode sink, Call login_call, Name name
where config.hasFlowPath(source, sink)
  and name.getId() = "login_user" 
  and login_call.getFunc() = name
  and (DataFlow::localFlow(DataFlow::exprNode(login_call), DataFlow::exprNode(sink.getNode().asExpr()))
  or DataFlow::localFlow(DataFlow::exprNode(sink.getNode().asExpr()), DataFlow::exprNode(login_call)))
  */
  /*
  and (login_call.getAFlowNode().getBasicBlock().reaches(sink.getNode().asCfgNode().getBasicBlock())
  or sink.getNode().asCfgNode().getBasicBlock().reaches(login_call.getAFlowNode().getBasicBlock()))
  */
/*
select sink.getNode(), source, sink, "Untrusted URL redirection after login depends on a $@.", source.getNode(), "user-provided value",
  login_call, login_call.getLocation()
*/