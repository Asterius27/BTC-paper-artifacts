import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask
import semmle.python.dataflow.new.DataFlow2

/* This doesn't work
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

/* Interprocedural reachability query which also checks that the barrier control flow node is not in the path between source and sink
predicate reachesWithBarrier(ControlFlowNode source, ControlFlowNode sink, ControlFlowNode barrier) {
    source.strictlyReaches(sink)
    and not (source.strictlyReaches(barrier) and barrier.strictlyReaches(sink))
    and exists(sink.getLocation().getFile().getRelativePath())
    and exists(source.getLocation().getFile().getRelativePath())
    or exists(Call c, Function f | 
        source.strictlyReaches(c.getAFlowNode())
        and not (source.strictlyReaches(barrier) and barrier.strictlyReaches(c.getAFlowNode()))
        and c.getFunc().toString() = f.getName()
        and exists(c.getLocation().getFile().getRelativePath())
        and exists(f.getLocation().getFile().getRelativePath())
        and reaches(f.getAFlowNode(), sink))
}
*/

// Interprocedural reachability query
// TODO this might lead to infite recursion, have to put a time limit (or something) when running this query
predicate reaches(ControlFlowNode source, ControlFlowNode sink) {
    source.strictlyReaches(sink)
    and exists(sink.getLocation().getFile().getRelativePath())
    and exists(source.getLocation().getFile().getRelativePath())
    or exists(Call c, Function f | 
        source.strictlyReaches(c.getAFlowNode())
        and c.getFunc().toString() = f.getName()
        and exists(c.getLocation().getFile().getRelativePath())
        and exists(f.getLocation().getFile().getRelativePath())
        and reaches(f.getAFlowNode(), sink))
}

from DataFlow::Node source, DataFlow::Node sink
where source = API::moduleImport("flask").getMember("Flask").getAValueReachableFromSource()
    and not source.asExpr() instanceof ImportMember
    and exists(source.getLocation().getFile().getRelativePath())
    and exists(source.asCfgNode())
    and sink = Flask::FlaskApp::instance().getMember("config").getAValueReachableFromSource()
    and exists(sink.getLocation().getFile().getRelativePath())
    and exists(sink.asCfgNode())
    and not reaches(source.asCfgNode(), sink.asCfgNode())
select "Some configuration changes are made after the initialization phase", sink.getLocation()

/* TODO This is too slow, need to find a way to make it faster if we decide to use it
from DataFlow::Node source, DataFlow::Node sink, DataFlow::Node barrier
where source = API::moduleImport("flask").getMember("Flask").getAValueReachableFromSource()
    and not source.asExpr() instanceof ImportMember
    and exists(source.getLocation().getFile().getRelativePath())
    and sink = Flask::FlaskApp::instance().getMember("config").getAValueReachableFromSource()
    and exists(sink.getLocation().getFile().getRelativePath())
    and barrier = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
    and not barrier.asExpr() instanceof ImportMember
    and exists(barrier.getLocation().getFile().getRelativePath())
    and reachesWithBarrier(source.asCfgNode(), sink.asCfgNode(), barrier.asCfgNode())
select source, sink, source.getLocation(), sink.getLocation()
*/

/* This works
from DataFlow::Node source, DataFlow::Node sink
where source = API::moduleImport("flask").getMember("Flask").getAValueReachableFromSource()
    and not source.asExpr() instanceof ImportMember
    and exists(source.getLocation().getFile().getRelativePath())
    and sink = Flask::FlaskApp::instance().getMember("config").getAValueReachableFromSource()
    and exists(sink.getLocation().getFile().getRelativePath())
    and reaches(source.asCfgNode(), sink.asCfgNode())
select source, sink, source.getLocation(), sink.getLocation()
*/

/* This works (interprocedural), but isn't recursive
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
*/

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
