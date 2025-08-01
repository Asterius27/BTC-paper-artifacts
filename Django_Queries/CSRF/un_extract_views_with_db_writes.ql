import python
import CodeQL_Library.DjangoSession

class DBConfig extends DataFlow4::Configuration {
    DBConfig() { this = "DBConfig" }

    override predicate isSource(DataFlow4::Node source) {
        exists(AssignStmt asgn | 
            asgn.getATarget() = source.asExpr()
            and exists(source.getLocation().getFile().getRelativePath()))
    }

    override predicate isSink(DataFlow4::Node sink) {
        sink.asExpr() instanceof Name
        and exists(sink.getLocation().getFile().getRelativePath())
    }
}

Class classViewContainsNode(ControlFlowNode node) {
    exists(Class cls |
        cls = DjangoSession::getClassViews()
        and cls.getAMethod().getBody().contains(node.getNode())
        and result = cls)
}

Function functionViewContainsNode(ControlFlowNode node) {
    exists(Function f |
        f = DjangoSession::getFunctionViews()
        and f.getBody().contains(node.getNode())
        and result = f)
}

Expr getTopObject(Attribute atr) {
    if atr.getObject() instanceof Attribute or atr.getObject().(Call).getFunc() instanceof Attribute
    then result = getTopObject(atr.getObject())
        or result = getTopObject(atr.getObject().(Call).getFunc())
    else if exists(DataFlow4::Node source, DataFlow4::Node sink, DBConfig config | config.hasFlow(source, sink) and sink.asExpr() = atr.getObject())
        then exists(DataFlow4::Node source, DataFlow4::Node sink, DBConfig config | 
            config.hasFlow(source, sink)
            and sink.asExpr() = atr.getObject()
            and exists(AssignStmt asgn |
                asgn.getATarget() = source.asExpr()
                and if asgn.getValue() instanceof Attribute or asgn.getValue().(Call).getFunc() instanceof Attribute
                    then result = getTopObject(asgn.getValue())
                    else result = asgn.getValue()))
        else result = atr.getObject()
}

from Attribute atr, Class cls, ClassExpr clse, DataFlow::Node model, ControlFlowNode cfn
where (atr.getName() = "update"
        or atr.getName() = "save"
        or atr.getName() = "create"
        or atr.getName() = "bulk_create"
        or atr.getName() = "get_or_create"
        or atr.getName() = "update_or_create"
        or atr.getName() = "bulk_update"
        or atr.getName() = "add"
        or atr.getName() = "delete"
        or atr.getName() = "remove"
        or atr.getName() = "clear"
        or atr.getName() = "set")
    and exists(atr.getLocation().getFile().getRelativePath())
    and (clse.getAFlowNode() = getTopObject(atr).(Name).pointsTo().(ClassValue).getOrigin()
        or clse.getAFlowNode() = getTopObject(atr).(Call).getFunc().(Name).pointsTo().(ClassValue).getOrigin())
    and cls = clse.getInnerScope()
    and model = API::moduleImport("django").getMember("db").getMember("models").getMember("Model").getAValueReachableFromSource()
    and cls.getABase() = model.asExpr()
    and (cfn = classViewContainsNode(atr.getAFlowNode()).getEntryNode()
        or cfn = functionViewContainsNode(atr.getAFlowNode()).getEntryNode())
select cfn, cfn.getLocation(), "This view writes data in the database"
