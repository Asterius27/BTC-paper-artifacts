import python
import semmle.python.ApiGraphs

from ControlFlowNode cfn
where exists(DataFlow::Node password |
        (password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getReturn().getMember("cleaned_data").getAValueReachableFromSource()
            or password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("BaseUserCreationForm").getReturn().getMember("cleaned_data").getAValueReachableFromSource()
            or password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getReturn().getMember("data").getAValueReachableFromSource()
            or password = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("BaseUserCreationForm").getReturn().getMember("data").getAValueReachableFromSource())
        and not password.asExpr() instanceof ImportMember
        and exists(password.asCfgNode())
        and exists(password.getLocation().getFile().getRelativePath())
        and cfn = password.asCfgNode())
    or exists(Class cls, AssignStmt asgn, Attribute atr, Variable v |
        (cls.getABase() = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getAValueReachableFromSource().asExpr()
            or cls.getABase() = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("BaseUserCreationForm").getAValueReachableFromSource().asExpr())
        and (atr.getAttr() = "cleaned_data"
            or atr.getAttr() = "data")
        and atr.getObject().(Name).getId() = v.getId()
        and v.getAStore() = asgn.getATarget()
        and asgn.getValue() = cls.getClassObject().getACall().getNode()
        and cfn = atr.getAFlowNode())
select cfn, cfn.getLocation(), "Django's built in user creation form's fields are being accessed"
