import python
import semmle.python.ApiGraphs

DataFlow::Node inlineCustomValidators() {
    exists(Class cls | 
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
        and exists(DataFlow::Node node | 
            node = API::moduleImport("wtforms").getMember("PasswordField").getAValueReachableFromSource()
            and exists(cls.getLocation().getFile().getRelativePath())
            and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.asExpr()
            and result = node)
        and cls.getAMethod().getName().prefix(9) = "validate_")
}

DataFlow::Node customValidators() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("wtforms").getMember("PasswordField").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("wtforms").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink())
        and exists(ControlFlowNode element | 
            element = node.asExpr().(List).getAnElt().getAFlowNode() | 
            forall(API::Node validator | 
                validator = API::moduleImport("wtforms").getMember("validators").getAMember() |
                validator.getReturn().getAValueReachableFromSource().asCfgNode() != element))
        and result = node)
}

from DataFlow::Node passfield
where passfield = customValidators()
    or passfield = inlineCustomValidators()
select passfield, passfield.getLocation(), "Using a custom validator to check password strength"
