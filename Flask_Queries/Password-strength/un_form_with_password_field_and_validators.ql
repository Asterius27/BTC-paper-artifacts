import python
import semmle.python.ApiGraphs

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