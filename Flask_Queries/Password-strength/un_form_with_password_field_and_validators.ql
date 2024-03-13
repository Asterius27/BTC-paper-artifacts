import python
import semmle.python.ApiGraphs

predicate passwordFieldHasValidators(API::Node node) {
    exists(node.getParameter(1).getAValueReachingSink())
    or exists(node.getKeywordParameter("validators").getAValueReachingSink())
}

from Class cls, API::Node node, AssignStmt asgn, Call call
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm"
        or cls.getABase().toString() = "FlaskForm")
    and (node = API::moduleImport("wtforms").getMember("PasswordField")
        or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
    // and cls.getAMethod().getName().prefix(9 + asgn.getATarget().(Name).getId().length()) = "validate_" + asgn.getATarget().(Name).getId()
    and asgn = cls.getAStmt().(AssignStmt)
    and asgn.getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr()
    and call = asgn.getValue().(Call)
select cls, cls.getLocation(), asgn, asgn.getLocation(), call.getNamedArg(0) //call.getPositionalArg(1), "This form has a password field with some validators"

/*
from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm"
        or cls.getABase().toString() = "FlaskForm")
    and exists(API::Node node, AssignStmt asgn | 
        (node = API::moduleImport("wtforms").getMember("PasswordField")
            or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
        and (exists(node.getParameter(1).getAValueReachingSink())
            or exists(node.getKeywordParameter("validators").getAValueReachingSink())
            or cls.getAMethod().getName().prefix(9 + asgn.getATarget().(Name).getId().length()) = "validate_" + asgn.getATarget().(Name).getId())
        and asgn = cls.getAStmt().(AssignStmt)
        and asgn.getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
select cls, cls.getLocation(), "This form has a password field with some validators"
*/
