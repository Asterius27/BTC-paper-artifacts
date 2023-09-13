import python
import semmle.python.security.dataflow.UrlRedirectQuery
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow2
// import semmle.python.frameworks.Flask
// import DataFlow::PathGraph // (used to print the edges)
// import semmle.python.dataflow.new.internal.DataFlowDispatch

// TODO doesn't work if there is a function call in the guard (the if before the redirect), 
// only works if the variable is explicitly checked inside the if (with a == or others)
// source: https://github.com/github/codeql/blob/main/python/ql/src/Security/CWE-601/UrlRedirect.ql

class LoginDataFlowConfiguration extends DataFlow2::Configuration {
  LoginDataFlowConfiguration() { this = "LoginDataFlowConfiguration" }

  override predicate isSource(DataFlow2::Node source) {
    source = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
    and not source.asExpr() instanceof ImportMember
    and exists(source.asCfgNode())
    and exists(source.getLocation().getFile().getRelativePath())
    // 1 = 1
    // source instanceof Sink
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
  }

  override predicate isSink(DataFlow2::Node sink) {
    // 1 = 1
    sink instanceof Sink
    // sink.asExpr().toString() = "next"
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
    // sink instanceof DataFlow::Node
    /*exists(Name name |
      name.getId() = "next"
      and sink.asExpr() = name)*/
  }

  /*
  override predicate isBarrierOut(DataFlow2::Node barrier) {
    barrier instanceof Sink
  }

  override predicate isBarrierIn(DataFlow2::Node barrier) {
    barrier = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
    and barrier.asExpr().toString() = "login_user"
  }
  */

  // Works, but it's slow (faster if given more threads) and uses a lot of memory
  // When also including the library files (so without the lines: and exists(c.getLocation().getFile().getRelativePath()), and exists(f.getLocation().getFile().getRelativePath()))), the following happens:
  // if there is more than one login_user call and at least one of them reaches the open redirect sink, then all of the login_user calls will be displayed in the results of the query (even the ones that do not reach the sink)
  // and if a sink is reachable by a login_user call, then it returns all possible sinks that are in the program instead of only the reachable sink
  // don't know why but it's as if the library files break the call graph that is constructed by the isAdditionalFlowStep (might be because getAValueReachableFromSource() in isSource() is already interprocedural)
  // also it's better to not include the library files for performance reasons
  // SO ALWAYS CHECK THAT THE PACKAGES/LIBRARIES ARE NOT IN THE SAME DIRECTORY AS THE USER WRITTEN FILES
  override predicate isAdditionalFlowStep(DataFlow2::Node fromNode, DataFlow2::Node toNode) {
    fromNode.asCfgNode().getASuccessor() = toNode.asCfgNode()
    // or fromNode.asExpr().toString() = toNode.getEnclosingCallable().getQualifiedName()
    // or fromNode.getEnclosingCallable().getQualifiedName() = toNode.asExpr().toString()
    /*
    or exists(Function f, Call c | 
      c.getAFlowNode() = fromNode.asCfgNode()
      and f = toNode.getScope()
      and c.getFunc().toString() = f.getName())
    */
    or exists(Function f, Call c | 
      f = fromNode.getScope()
      and c.getFunc().toString() = f.getName()
      and c.getAFlowNode() = toNode.asCfgNode()
      and exists(c.getLocation().getFile().getRelativePath())
      and exists(f.getLocation().getFile().getRelativePath()))
    /*
      and not exists(string str | 
        str = Flask::FlaskApp::instance().getAValueReachableFromSource().getLocation().toString()
        and str = f.getADecorator().getLocation().toString()))
    */
    /*
    and not exists(Call a, Call b |
      a.getAFlowNode() = fromNode.asCfgNode()
      and b.getAFlowNode() = toNode.asCfgNode()
      and a.getFunc() = b.getFunc())
    */
  }
}

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

/*
query predicate edges(DataFlow2::PathNode a, DataFlow2::PathNode b) {
  exists(Function f, Call c | 
    f = a.getScope()
    and c.getFunc().toString() = f.getName()
    and c.getAFlowNode() = b.asCfgNode())
}
*/

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

/*
from Function f, DataFlow2::Node source, Call c
where source = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
  and source.asExpr().toString() = "login_user"
  and f = source.getScope()
  and c.getFunc().toString() = f.getName()
select f, f.getLocation(), c, c.getLocation(), f.getLocation().getFile().getRelativePath(), c.getLocation().getFile().getRelativePath()
*/

/*
from Function f
where f.getName().matches("login")
  and exists(string str | 
    str = Flask::FlaskApp::instance().getAValueReachableFromSource().getLocation().toString()
    and str = f.getADecorator().getLocation().toString())
select f, f.getLocation(), f.getADecorator().getLocation()
*/

// select Flask::FlaskApp::instance().getAValueReachableFromSource().asExpr(), Flask::FlaskApp::instance().getAValueReachableFromSource().asExpr().getLocation(), Flask::FlaskApp::instance().getAValueReachableFromSource().getLocation()

/*
from LoginDataFlowConfiguration lconfig, DataFlow2::PathNode login, DataFlow2::PathNode redirect
where lconfig.hasFlowPath(login, redirect)
select login, redirect, login.getNode().getLocation(), redirect.getNode().getLocation()
*/

from Configuration config, DataFlow::PathNode source, DataFlow::PathNode sink, LoginDataFlowConfiguration lconfig, DataFlow2::PathNode login, DataFlow2::PathNode redirect
where 
  config.hasFlowPath(source, sink)
  and sink.getNode() = redirect.getNode()
  and lconfig.hasFlowPath(login, redirect)
  // getLoginGraph(source, sink)
  // source = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
  // and source.asExpr().toString() = "login_user"
select source, sink, login, redirect, source.getNode().getLocation(), sink.getNode().getLocation(), login.getNode().getLocation(), redirect.getNode().getLocation()

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

/* TODO Not interprocedural, but works and has no performance issues (should change some things: 
  use API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource() to find the correct function and
  source is always login_user and sink is always the open redirect sink)
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
