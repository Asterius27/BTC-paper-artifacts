import python
import semmle.python.ApiGraphs

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm"
        or cls.getABase().toString() = "FlaskForm")
    and exists(DataFlow::Node node1, DataFlow::Node node2 | 
        node1 = API::moduleImport("wtforms").getMember("PasswordField").getAValueReachableFromSource()
        and node2 = API::moduleImport("wtforms").getMember("PasswordField").getAValueReachableFromSource()
        and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node1.asExpr()
        and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node2.asExpr()
        and node1 != node2)
select cls, cls.getLocation(), "This form has two password fields, so it's likely that it is a sign up or password reset form"
