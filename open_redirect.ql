import python
// import semmle.python.security.dataflow.UrlRedirectQuery
import semmle.python.ApiGraphs
// import semmle.python.dataflow.new.DataFlow
// import DataFlow::PathGraph

// TODO doesn't work if there is a function call in the guard (the if before the redirect), 
// only works if the variable is explicitly checked inside the if (with a == or others)
// source: https://github.com/github/codeql/blob/main/python/ql/src/Security/CWE-601/UrlRedirect.ql

// TODO finish interprocedural flow analysis (between next variable and login_user)
// TODO sink might be before the login_user call

/*
class LoginDataFlowConfiguration extends DataFlow::Configuration {
  LoginDataFlowConfiguration() { this = "LoginDataFlowConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    1 = 1
    */
    /*
    source = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
    and source.asExpr().toString() = "login_user"
    */
    // source.asExpr().toString() = "next"
    /*exists(Call login_call, Name name | 
      name.getId() = "login_user" 
      and login_call.getFunc() = name
      and source.asExpr() = login_call)*/
    // or source instanceof Source
    // source.asExpr().toString() = "next"
    /*
    exists(DataFlow::Node node |
      node = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
      and node.asExpr().toString() = "login_user"
      and source = node)
    */
  // }

  /*
  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr().toString() = "next"
    */
    /*
    sink = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
    and sink.asExpr().toString() = "login_user"
    */
    /*
    exists(Call login_call, Name name | 
      name.getId() = "login_user" 
      and login_call.getFunc() = name
      and sink.asExpr() = login_call)
    */
    // sink instanceof Sink
    // sink instanceof DataFlow::Node
    /*exists(Name name |
      name.getId() = "next"
      and sink.asExpr() = name)*/
  // }
// }


/* This selects the login_user call
from DataFlow::Node node
where node = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
  and node.asExpr().toString() = "login_user"
select node.getLocation(), node.asExpr()
*/

/* This finds the open redirect vulnerability
from Configuration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select source, sink, source.getNode().getLocation(), sink.getNode().getLocation(), source.getNode(), sink.getNode()
*/

query predicate edges(DataFlow::Node a, DataFlow::Node b) {
  a.asCfgNode().getASuccessor() = b.asCfgNode()
  and a = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
  and a.asExpr().toString() = "login_user"
}

/*
predicate getLoginGraph(DataFlow::PathNode source, DataFlow::PathNode sink) {
  edges+(source, sink)
  */
  /*
  and sink.getNode().asExpr().toString() = "next"
  and source.getNode() = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
  and source.getNode().asExpr().toString() = "login_user"
  */
// }

from DataFlow::Node source
where 
  // config.hasFlowPath(source, sink)
  // lconfig.hasFlowPath(source, sink)
  // getLoginGraph(source, sink)
  source = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
  and source.asExpr().toString() = "login_user"
select source, source.getLocation()

/*
from Configuration config, LoginDataFlowConfiguration lconfig, DataFlow::PathNode source, DataFlow::PathNode sink, 
  DataFlow::PathNode login_call, DataFlow::Node sink2
where
  config.hasFlowPath(source, sink)
  // lconfig.hasFlow(sink2, login_call)
  // or lconfig.hasFlow(sink.getNode(), login_call))
select sink.getNode(), source, sink, "Untrusted URL redirection after login depends on a $@.", source.getNode(), "user-provided value",
  login_call, login_call.getNode().getLocation(), sink.getNode().getLocation(), sink.getNode().asExpr(), source.getNode().getLocation(), source.getNode().asExpr()
*/

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
