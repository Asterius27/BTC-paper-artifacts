import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

Class classViewContainsNode(ControlFlowNode node) {
    exists(Class cls |
        cls = FlaskLogin::getClassViews()
        and cls.getAMethod().getBody().contains(node.getNode())
        and result = cls)
}

Function functionViewContainsNode(ControlFlowNode node) {
    exists(Function f |
        f = FlaskLogin::getFunctionViews()
        and f.getBody().contains(node.getNode())
        and result = f)
}

string getViewNameAndLocation(Class cls) {
    if exists(classViewContainsNode(cls.getClassObject().getACall())) or exists(functionViewContainsNode(cls.getClassObject().getACall()))
    then exists(ControlFlowNode cfn |
        (cfn = classViewContainsNode(cls.getClassObject().getACall()).getEntryNode()
            or cfn = functionViewContainsNode(cls.getClassObject().getACall()).getEntryNode())
        and result = cfn + " | " + cfn.getLocation())
    else result = "No class or view found"
}

from DataFlow::Node node, Class cls
where node = API::moduleImport("flask_wtf").getMember("FlaskForm").getAValueReachableFromSource()
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
    and cls.getABase().getAFlowNode() = node.asCfgNode()
select node, node.getLocation(), cls.getName(), getViewNameAndLocation(cls), "FlaskForm is being used, which already has csrf protection enabled"
