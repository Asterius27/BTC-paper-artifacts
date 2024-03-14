import python
import semmle.python.ApiGraphs

from Class cls, API::Node node, AssignStmt asgn, Call call
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm"
        or cls.getABase().toString() = "FlaskForm")
    and (node = API::moduleImport("wtforms").getMember("PasswordField")
        or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
    and asgn = cls.getAStmt().(AssignStmt)
    and asgn.getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr()
    and call = asgn.getValue().(Call)
    and (exists(call.getPositionalArg(1))
        or call.getANamedArgumentName() = "validators"
        or cls.getAMethod().getName().prefix(9 + asgn.getATarget().(Name).getId().length()) = "validate_" + asgn.getATarget().(Name).getId())
select cls, cls.getLocation(), "This form has a password field with some validators"
