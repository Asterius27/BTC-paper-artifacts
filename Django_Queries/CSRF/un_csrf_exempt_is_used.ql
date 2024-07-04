import python
import semmle.python.ApiGraphs
import CodeQL_Library.DjangoSession

Function getDecoratedFunction(ControlFlowNode node) {
    exists(Function f |
        (f.getADecorator().getAFlowNode() = node
            or f.getADecorator().getAChildNode().getAFlowNode() = node)
        and result = f)
    or exists(Function f, ControlFlowNode cfn, Call cl |
        cfn = API::moduleImport("django").getMember("utils").getMember("decorators").getMember("method_decorator").getACall().asCfgNode()
        and f.getADecorator().getAFlowNode() = cfn
        and cfn = cl.getAFlowNode()
        and (cl.getAPositionalArg().getAFlowNode() = node
            or cl.getAPositionalArg().getAChildNode().getAFlowNode() = node
            or cl.getANamedArg().(Keyword).getValue().getAFlowNode() = node
            or cl.getANamedArg().(Keyword).getValue().getAChildNode().getAFlowNode() = node)
        and result = f)
}

Class getDecoratedClass(ControlFlowNode node) {
    exists(Class c, ControlFlowNode cfn, Call cl |
        cfn = API::moduleImport("django").getMember("utils").getMember("decorators").getMember("method_decorator").getACall().asCfgNode()
        and c.getADecorator().getAFlowNode() = cfn
        and cfn = cl.getAFlowNode()
        and (cl.getAPositionalArg().getAFlowNode() = node
            or cl.getAPositionalArg().getAChildNode().getAFlowNode() = node
            or cl.getANamedArg().(Keyword).getValue().getAFlowNode() = node
            or cl.getANamedArg().(Keyword).getValue().getAChildNode().getAFlowNode() = node)
        and result = c)
}

Function getArgumentFunction(Expr node) {
    exists(Call c, Expr expr, Function f |
        c.getFunc().(Name) = node.(Name)
        and exists(node.getLocation().getFile().getRelativePath())
        and (c.contains(expr)
            or c.getNamedArg(0).(Keyword).contains(expr))
        and (expr.(Attribute).getName() = f.getName()
            or expr.(Name).getId() = f.getName())
        and not exists(Function func | func.getADecorator() = node or func.getADecorator().getAChildNode() = node)
        and result = f)
}

Class getArgumentClass(Expr node) {
    exists(Call c, Expr expr, Class cls |
        c.getFunc().(Name) = node.(Name)
        and exists(node.getLocation().getFile().getRelativePath())
        and (c.contains(expr)
            or c.getNamedArg(0).(Keyword).contains(expr))
        and (expr.(Attribute).getName() = cls.getName()
            or expr.(Name).getId() = cls.getName())
        and not exists(Function func | func.getADecorator() = node or func.getADecorator().getAChildNode() = node)
        and result = cls)
}

from DataFlow::Node node, ControlFlowNode cfn, string name
where node = API::moduleImport("django").getMember("views").getMember("decorators").getMember("csrf").getMember("csrf_exempt").getAValueReachableFromSource()
    and not node.asCfgNode().isImportMember()
    and not exists(ImportingStmt stmt | stmt.contains(node.asCfgNode().getNode()))
    and exists(node.asCfgNode())
    and if exists(getArgumentFunction(node.asExpr())) or exists(getArgumentClass(node.asExpr())) or exists(getDecoratedFunction(node.asCfgNode())) or exists(getDecoratedClass(node.asCfgNode()))
        then (cfn = getArgumentFunction(node.asExpr()).getEntryNode()
                or cfn = getArgumentClass(node.asExpr()).getEntryNode()
                or cfn = getDecoratedFunction(node.asCfgNode()).getEntryNode()
                or cfn = getDecoratedClass(node.asCfgNode()).getEntryNode())
            and name = cfn.toString() + " | " + cfn.getLocation().toString()
            and exists(cfn.getLocation().getFile().getRelativePath())
            and (cfn = DjangoSession::getClassViews().getEntryNode()
                or cfn = DjangoSession::getFunctionViews().getEntryNode()
                or cfn = DjangoSession::getClassViews().getAMethod().getEntryNode())
        else name = "No class or view found"
select node, node.getLocation(), name, "The application is disabling csrf protection for certain views"
