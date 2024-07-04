import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

from DataFlow::Node password, DataFlow::Node pattern, API::CallNode call
where call = API::moduleImport("re").getAMember().getACall()
    and password = call.getParameter(1, "string").getAValueReachingSink()
    and exists(password.getLocation().getFile().getRelativePath())
    and pattern = call.getParameter(0, "pattern").getAValueReachingSink()
    and exists(pattern.getLocation().getFile().getRelativePath())
    and exists(Class cls, Attribute atr, AssignStmt asgn, Variable v |
        cls = FlaskLogin::getSignUpFormClass()
        and atr.getAttr() = FlaskLogin::getPasswordFieldName(cls)
        and atr.getObject().(Name).getId() = v.getId()
        and v.getAStore() = asgn.getATarget()
        and asgn.getValue() = cls.getClassObject().getACall().getNode()
        and atr = password.asExpr())
select pattern.asExpr().(StrConst).getS(), pattern.getLocation(), password, password.getLocation(), "The password is manually checked against a regexp"
