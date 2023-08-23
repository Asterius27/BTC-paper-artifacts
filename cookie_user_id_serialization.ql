import python
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.Concepts
import semmle.python.objects.ObjectInternal

// TODO intraprocedural version of the query
// TODO extend to any object that is passed to the login_user function (check that the object's get_id function returns something that is not constant nor user controlled data)
// but I don't know how to statically find the type (class) of an object (needed to then retrieve the object's get_id function) (probably impossible) 
/*
from DataFlow::Node node
where node = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("user").getAValueReachingSink()
    or node = API::moduleImport("flask_login").getMember("login_user").getParameter(0).getAValueReachingSink()
select node, node.getLocation(), node.asExpr()
*/

// maybe somthing like a dataflow analysis from a remoteflowsource into the id field of any object of type User (or in general any class that extends UserMixin)

/*
predicate override(ControlFlowNode node, DataFlow::Node sink, ClassValue cls) {
    cls.declaresAttribute("get_id")
}

predicate nooverride(ControlFlowNode node, DataFlow::Node sink, ClassValue cls) {
    exists(AttrNode attr, AssignStmt asgn | 
        attr.getName() = "id"
        and attr.getObject() = node
        and asgn.getATarget() = attr.getNode()
        and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        and not cls.declaresAttribute("get_id")
    )
}

predicate aux(ControlFlowNode node, DataFlow::Node sink, ClassValue cls) {
    nooverride(node, sink, cls) or override(node, sink, cls)
} 

// This worked
class CookieConfiguration extends DataFlow::Configuration {
    CookieConfiguration() { this = "CookieConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source instanceof RemoteFlowSource
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(ClassValue cls, ControlFlowNode node | 
            cls.getASuperType().getName() = "UserMixin" 
            and node.pointsTo().getClass() = cls
            and aux(node, sink, cls)
            // and attr.getName() = "id"
            // and attr.getObject() = node
            // and asgn.getATarget() = attr.getNode()
            // and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, CookieConfiguration config
where config.hasFlow(source, sink)
select source, sink, source.getLocation(), sink.getLocation()
*/

from ClassValue cls, Function f
where cls.getASuperType().getName() = "UserMixin"
    and cls.getName() != "UserMixin"
    and cls.declaresAttribute("get_id")
    and f = cls.declaredAttribute("get_id")
select cls, cls.getClass(), f


/* This works
from ClassValue cls, ControlFlowNode node, AttrNode attr, AssignStmt asgn
where cls.getASuperType().getName() = "UserMixin" 
    and node.pointsTo().getClass() = cls
    and attr.getName() = "id"
    and attr.getObject() = node
    and asgn.getATarget() = attr.getNode()
select cls, attr, attr.getLocation()
*/
