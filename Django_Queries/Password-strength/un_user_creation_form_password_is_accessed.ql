import python
import semmle.python.ApiGraphs

from ControlFlowNode cfn
where exists(DataFlow::Node password |
        (password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getReturn().getMember("password1").getAValueReachableFromSource()
            or password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getReturn().getMember("password2").getAValueReachableFromSource()
            or password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("BaseUserCreationForm").getReturn().getMember("password1").getAValueReachableFromSource()
            or password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("BaseUserCreationForm").getReturn().getMember("password2").getAValueReachableFromSource())
        and not password.asExpr() instanceof ImportMember
        and exists(password.asCfgNode())
        and exists(password.getLocation().getFile().getRelativePath())
        and cfn = password.asCfgNode())
    or exists(Class cls, AssignStmt asgn, Attribute atr, Variable v |
        (cls.getABase() = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getAValueReachableFromSource().asExpr()
            or cls.getABase() = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("BaseUserCreationForm").getAValueReachableFromSource().asExpr())
        and (atr.getAttr() = "password1"
            or atr.getAttr() = "password2")
        and atr.getObject().(Name).getId() = v.getId()
        and v.getAStore() = asgn.getATarget()
        and asgn.getValue() = cls.getClassObject().getACall().getNode()
        and cfn = atr.getAFlowNode())
select cfn, cfn.getLocation(), "Django's built in user creation form's password field is being accessed"
