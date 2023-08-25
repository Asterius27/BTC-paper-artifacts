import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// TODO intraprocedural version of the query
// TODO extend to any object that is passed to the login_user function (check that the object's get_id function returns something that is not user controlled data)
// but I don't know how to statically find the type (class) of an object (needed to then retrieve the object's get_id function) (probably impossible)
// and I don't know how to define "user controlled data"
/*
from DataFlow::Node node
where node = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("user").getAValueReachingSink()
    or node = API::moduleImport("flask_login").getMember("login_user").getParameter(0).getAValueReachingSink()
select node, node.getLocation(), node.asExpr()
*/

// It's a dataflow analysis from an immutable literal into the id field of any object of a type (class) that extends UserMixin or into the return value of the overriden get_id method
// TODO if the function (get_id) returns an attribute of self (e.g. return self.username), the data flow doesn't work
predicate override(DataFlow::Node sink, ClassValue cls) {
    exists(Function f |
        cls.getName() != "UserMixin"
        and cls.declaresAttribute("get_id")
        and f.getDefinition().getAFlowNode() = cls.declaredAttribute("get_id").getAReference()
        and f.getAReturnValueFlowNode() = sink.asCfgNode()
    )
}

predicate nooverride(DataFlow::Node sink, ClassValue cls) {
    exists(AttrNode attr, AssignStmt asgn, ControlFlowNode node | 
        attr.getName() = "id"
        and node.pointsTo().getClass() = cls
        and attr.getObject() = node
        and asgn.getATarget() = attr.getNode()
        and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        and not cls.declaresAttribute("get_id")
    )
}

predicate aux(DataFlow::Node sink, ClassValue cls) {
    nooverride(sink, cls) or override(sink, cls)
} 

class CookieConfiguration extends DataFlow::Configuration {
    CookieConfiguration() { this = "CookieConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof ImmutableLiteral
        and exists(source.getLocation().getFile().getRelativePath())
        /*
        source = API::moduleImport("flask").getMember("request").getAValueReachableFromSource()
        and exists(source.getLocation().getFile().getRelativePath())
        and source.asExpr().toString() = "request"
        */
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(sink.getLocation().getFile().getRelativePath())
        and exists(ClassValue cls | 
            cls.getASuperType().getName() = "UserMixin"
            and aux(sink, cls)
        )
    }

    /*
    override predicate isAdditionalFlowStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
        toNode.getLocation().toString() = fromNode.getLocation().toString()
        // and isSink(toNode)
    }
    */
}

from DataFlow::Node source, DataFlow::Node sink, CookieConfiguration config
where config.hasFlow(source, sink)
select source, sink, source.getLocation(), sink.getLocation()

/*
from DataFlow::Node source
where source.asExpr() instanceof ImmutableLiteral
    and exists(source.getLocation().getFile().getRelativePath())
select source, source.getLocation()
*/

/*
from DataFlow::Node source, AttrNode attr
where source = API::moduleImport("flask").getMember("request").getAValueReachableFromSource()
    and exists(source.getLocation().getFile().getRelativePath())
    and source.asExpr().toString() = "request"
    and attr.getObject() = source.asCfgNode()
select source, source.getLocation(), attr.getName()
*/

/*
from AttrNode attr
where exists(attr.getLocation().getFile().getRelativePath())
select attr, attr.getObject(), attr.getLocation()
*/

/* This works
from DataFlow::Node sink, DataFlow::Node source
where exists(ClassValue cls | 
        cls.getASuperType().getName() = "UserMixin"
        and aux(sink, cls)
    )
    and exists(sink.getLocation().getFile().getRelativePath())
    and source = API::moduleImport("flask").getMember("request").getAValueReachableFromSource()
    and exists(source.getLocation().getFile().getRelativePath())
    and sink.getLocation().toString() = source.getLocation().toString()
select sink, sink.getLocation(), sink.asExpr(), source, source.getLocation()
*/

/* This works
from ClassValue cls, Function f
where cls.getASuperType().getName() = "UserMixin"
    and cls.getName() != "UserMixin"
    and cls.declaresAttribute("get_id")
    and f.getDefinition().getAFlowNode() = cls.declaredAttribute("get_id").getAReference()
select cls, cls.declaredAttribute("get_id"), f, f.getLocation(), f.getAReturnValueFlowNode(), f.getReturnNode()
*/

/* This works
from ClassValue cls, ControlFlowNode node, AttrNode attr, AssignStmt asgn
where cls.getASuperType().getName() = "UserMixin" 
    and node.pointsTo().getClass() = cls
    and attr.getName() = "id"
    and attr.getObject() = node
    and asgn.getATarget() = attr.getNode()
select cls, attr, attr.getLocation()
*/
