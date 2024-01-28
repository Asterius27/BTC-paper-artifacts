import python
import semmle.python.ApiGraphs

// TODO doesn't seem to be working correctly
DataFlow::Node inlineCustomValidators() {
    exists(Class cls, DataFlow::Node node | 
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
        and (node = API::moduleImport("wtforms").getMember("PasswordField").getAValueReachableFromSource()
            or node = API::moduleImport("flask_wtf").getMember("PasswordField").getAValueReachableFromSource())
        and exists(cls.getLocation().getFile().getRelativePath())
        and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.asExpr()
        and cls.getAMethod().getName().prefix(9) = "validate_"
        and result = node)
}

DataFlow::Node customValidators() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("wtforms").getMember("PasswordField").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("flask_wtf").getMember("PasswordField").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("wtforms").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink()
            or node = API::moduleImport("flask_wtf").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink())
        and exists(ControlFlowNode element | 
            element = node.asExpr().(List).getAnElt().getAFlowNode() | 
            forall(API::Node validator | 
                validator = API::moduleImport("wtforms").getMember("validators").getAMember() |
                validator.getReturn().getAValueReachableFromSource().asCfgNode() != element))
        and result = node)
}

from DataFlow::Node passfield
where passfield = inlineCustomValidators()
//    or passfield = customValidators()
select passfield, passfield.getLocation(), "Using a custom validator to check password strength"
