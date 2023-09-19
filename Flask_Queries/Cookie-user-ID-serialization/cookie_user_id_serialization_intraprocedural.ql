import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// TODO extend to any object that is passed to the login_user function (check that the object's get_id function returns something that is not user controlled data)
// but I don't know how to statically find the type (class) of an object (needed to then retrieve the object's get_id function) (probably impossible)
// and I don't know how to define "user controlled data"
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

from DataFlow::ExprNode source, DataFlow::ExprNode sink
where source.asExpr() instanceof ImmutableLiteral
    and exists(source.getLocation().getFile().getRelativePath())
    and exists(sink.getLocation().getFile().getRelativePath())
    and exists(ClassValue cls | 
        cls.getASuperType().getName() = "UserMixin"
        and aux(sink, cls)
    )
    and DataFlow::localFlow(source, sink)
select source, sink, source.getLocation(), sink.getLocation()
