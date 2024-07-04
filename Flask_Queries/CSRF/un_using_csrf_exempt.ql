import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

Function getDecoratedFunction(ControlFlowNode node) {
    exists(Function f |
        (f.getADecorator().getAFlowNode() = node
            or f.getADecorator().getAChildNode().getAFlowNode() = node)
        and result = f)
}

Class getDecoratedClass(ControlFlowNode node) {
    exists(Class c |
        c = node.getScope()
        and c.getABase().getAFlowNode() = API::moduleImport("flask").getMember("views").getMember("View").getAValueReachableFromSource().asCfgNode()
        and c.getBody().getAnItem().(AssignStmt).getATarget().(Name).getId() = "decorators"
        and result = c)
}

Function getArgumentFunction(Expr node) {
    exists(Call c, Expr expr, Function f |
        c.getFunc().(Attribute) = node.(Attribute)
        and exists(node.getLocation().getFile().getRelativePath())
        and (c.contains(expr)
            or c.getNamedArg(0).(Keyword).contains(expr))
        and (expr.(Attribute).getName() = f.getName()
            or expr.(Name).getId() = f.getName())
        and exists(f.getLocation().getFile().getRelativePath())
        and not exists(Function fun | fun.getADecorator() = node or fun.getADecorator().getAChildNode() = node)
        and result = f)
}

Class getArgumentClass(Expr node) {
    exists(Call c, Expr expr, Class cls |
        c.getFunc().(Attribute) = node.(Attribute)
        and exists(node.getLocation().getFile().getRelativePath())
        and (c.contains(expr)
            or c.getNamedArg(0).(Keyword).contains(expr))
        and (expr.(Attribute).getName() = cls.getName()
            or expr.(Name).getId() = cls.getName())
        and exists(cls.getLocation().getFile().getRelativePath())
        and not exists(Function fun | fun.getADecorator() = node or fun.getADecorator().getAChildNode() = node)
        and result = cls)
}

from API::Node node, DataFlow::Node n, ControlFlowNode cfn, string name
where (node = API::moduleImport("flask_wtf").getMember("csrf").getMember("CSRFProtect")
        or node = API::moduleImport("flask_wtf").getMember("CSRFProtect"))
    and (exists(node.getParameter(0).getAValueReachingSink())
        or exists(node.getKeywordParameter("app").getAValueReachingSink())
        or exists(node.getReturn().getMember("init_app").getParameter(0).getAValueReachingSink())
        or exists(node.getReturn().getMember("init_app").getKeywordParameter("app").getAValueReachingSink()))
    and n = node.getReturn().getMember("exempt").getAValueReachableFromSource()
    and exists(n.asCfgNode())
    and not n.asExpr() instanceof ImportMember
    and not exists(ImportingStmt stmt | stmt.contains(n.asCfgNode().getNode()))
    and if exists(getArgumentFunction(n.asExpr())) or exists(getArgumentClass(n.asExpr())) or exists(getDecoratedFunction(n.asCfgNode())) or exists(getDecoratedClass(n.asCfgNode()))
        then (cfn = getArgumentFunction(n.asExpr()).getEntryNode()
                or cfn = getArgumentClass(n.asExpr()).getEntryNode()
                or cfn = getDecoratedFunction(n.asCfgNode()).getEntryNode()
                or cfn = getDecoratedClass(n.asCfgNode()).getEntryNode())
            and name = cfn.toString() + " | " + cfn.getLocation().toString()
            and exists(cfn.getLocation().getFile().getRelativePath())
            and (cfn = FlaskLogin::getClassViews().getEntryNode()
                or cfn = FlaskLogin::getFunctionViews().getEntryNode()
                or cfn = FlaskLogin::getClassViews().getAMethod().getEntryNode())
        else name = "No class or view found"
select n, n.getLocation(), name, "The application is disabling csrf protection for certain views"
