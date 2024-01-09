import python
import semmle.python.ApiGraphs

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm"
        or cls.getABase().toString() = "FlaskForm")
    and exists(API::Node node | 
        node = API::moduleImport("wtforms").getMember("PasswordField")
        and (exists(node.getParameter(1).getAValueReachingSink())
            or exists(node.getKeywordParameter("validators").getAValueReachingSink())
            or cls.getAMethod().getName().prefix(9) = "validate_")
        and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
select cls, cls.getLocation(), "This form has a password field with some validators"