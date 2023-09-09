import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask
import semmle.python.dataflow.new.DataFlow2

/* Doesn't work
class LoginDataFlowConfiguration extends DataFlow2::Configuration {
    LoginDataFlowConfiguration() { this = "LoginDataFlowConfiguration" }
  
    override predicate isSource(DataFlow2::Node source) {
        source = API::moduleImport("flask").getMember("Flask").getAValueReachableFromSource()
        and not source.asExpr() instanceof ImportMember
        and exists(source.getLocation().getFile().getRelativePath())
    }
  
    override predicate isSink(DataFlow2::Node sink) {
        sink = Flask::FlaskApp::instance().getMember("config").getAValueReachableFromSource()
        and exists(sink.getLocation().getFile().getRelativePath())
    }

    override predicate isBarrier(DataFlow2::Node node) {
        node = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
        and not node.asExpr() instanceof ImportMember
        and exists(node.getLocation().getFile().getRelativePath())
    }

    override predicate isAdditionalFlowStep(DataFlow2::Node fromNode, DataFlow2::Node toNode) {
        fromNode.asCfgNode().getASuccessor() = toNode.asCfgNode()
        or exists(Function f, Call c | 
            f = fromNode.getScope()
            and c.getFunc().toString() = f.getName()
            and c.getAFlowNode() = toNode.asCfgNode()
            and exists(c.getLocation().getFile().getRelativePath())
            and exists(f.getLocation().getFile().getRelativePath()))
    }
}

from DataFlow2::Node source, DataFlow2::Node sink, LoginDataFlowConfiguration config
where config.hasFlow(source, sink)
select source, source.getLocation(), sink, sink.getLocation()
*/

predicate reaches(ControlFlowNode source, ControlFlowNode sink) {
    source.strictlyReaches(sink)
    and exists(sink.getLocation().getFile().getRelativePath())
    and exists(source.getLocation().getFile().getRelativePath())
    or exists(Call c | 
        source.strictlyReaches(c.getAFlowNode())
        and exists(c.getLocation().getFile().getRelativePath())
        and reaches(c.getFunc().getAFlowNode(), sink))
}

// TODO Should work (interprocedural), need to test it more thoroughly and implement it in the predicate with recursion (and then also add the login_user() node barrier)
// methods and classes are not taken into account (add them?)
from DataFlow::Node source, DataFlow::Node sink, Call c, Function f
where source = API::moduleImport("flask").getMember("Flask").getAValueReachableFromSource()
    and not source.asExpr() instanceof ImportMember
    and exists(source.getLocation().getFile().getRelativePath())
    and sink = Flask::FlaskApp::instance().getMember("config").getAValueReachableFromSource()
    and exists(sink.getLocation().getFile().getRelativePath())
    and source.asCfgNode().strictlyReaches(c.getAFlowNode())
    and c.getFunc().toString() = f.getName()
    and f.getAFlowNode().strictlyReaches(sink.asCfgNode())
select source, c, c.getLocation(), f, f.getLocation(), sink, sink.getLocation(), source.getLocation()

/* This works but is intraprocedural
from DataFlow::Node source, DataFlow::Node sink
where source = API::moduleImport("flask").getMember("Flask").getAValueReachableFromSource()
    and not source.asExpr() instanceof ImportMember
    and exists(source.getLocation().getFile().getRelativePath())
    and sink = Flask::FlaskApp::instance().getMember("config").getAValueReachableFromSource()
    and exists(sink.getLocation().getFile().getRelativePath())
    and source.asCfgNode().strictlyReaches(sink.asCfgNode())
select source, sink, source.getLocation(), sink.getLocation()
*/

/* This works (other ways of setting/updating multiple keys)
from DataFlow::Node node
where (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("REMEMBER_COOKIE_SAMESITE").getAValueReachingSink()
    and node.asExpr().toString() = "None")
    or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
    and node.asExpr().(Dict).getAnItem().(KeyValuePair).getKey().(Str).getText() = "REMEMBER_COOKIE_SAMESITE"
    and node.asExpr().(Dict).getAnItem().(KeyValuePair).getValue().toString() = "None")
select node.getLocation()
*/
