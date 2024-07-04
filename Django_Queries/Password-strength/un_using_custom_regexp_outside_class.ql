import python
import semmle.python.ApiGraphs

Name getPasswordField() {
    exists(DataFlow::Node form, AssignStmt asgn |
        form = API::moduleImport("django").getMember("forms").getMember("PasswordInput").getAValueReachableFromSource()
        and not form.asExpr() instanceof ImportMember
        and exists(form.asCfgNode())
        and exists(form.getLocation().getFile().getRelativePath())
        and asgn.getValue().contains(form.asExpr())
        and asgn.getATarget() = result)
}

Class getFormClass(Name field) {
    exists(Class cls |
        cls.getBody().contains(field.getAFlowNode().getNode())
        and result = cls)
}

from DataFlow::Node password, DataFlow::Node pattern, API::CallNode call
where call = API::moduleImport("re").getAMember().getACall()
    and password = call.getParameter(1, "string").getAValueReachingSink()
    and exists(password.getLocation().getFile().getRelativePath())
    and pattern = call.getParameter(0, "pattern").getAValueReachingSink()
    and exists(pattern.getLocation().getFile().getRelativePath())
    and exists(Class cls, Attribute atr, AssignStmt asgn, Variable v, Name field |
        cls = getFormClass(field)
        and field = getPasswordField()
        and atr.getAttr() = field.getId()
        and atr.getObject().(Name).getId() = v.getId()
        and v.getAStore() = asgn.getATarget()
        and asgn.getValue() = cls.getClassObject().getACall().getNode()
        and atr = password.asExpr())
select pattern.asExpr().(StrConst).getS(), pattern.getLocation(), password, password.getLocation(), "The password is manually checked against a regexp"
