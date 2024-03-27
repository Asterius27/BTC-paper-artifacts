import python
import semmle.python.ApiGraphs

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm"
        or cls.getABase().toString() = "FlaskForm")
    and exists(API::Node node | 
        (node = API::moduleImport("wtforms").getMember("PasswordField")
            or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
        and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
    and (cls.getName().toLowerCase().matches("%registration%")
        or cls.getName().toLowerCase().matches("%register%")
        or cls.getName().toLowerCase().matches("%createaccount%")
        or cls.getName().toLowerCase().matches("%signup%")
        or cls.getName().toLowerCase().matches("%adduser%")
        or cls.getName().toLowerCase().matches("%useradd%")
        or cls.getName().toLowerCase().matches("%regform%")
        or cls.getName().toLowerCase().matches("%newuser%")
        or cls.getName().toLowerCase().matches("%userform%")
        or cls.getName().toLowerCase().matches("%usersform%")
        or cls.getName().toLowerCase().matches("%registform%"))
select cls, cls.getLocation(), "This form has a password field and is probably a signup form"
