import python
import semmle.python.ApiGraphs

// TODO test this, check that the output for https://github.com/Ak500k/Passwd-Manager is correct (and also have a look at the other repos)
DataFlow::Node inlineCustomValidators() {
    exists(Class cls, DataFlow::Node node, AssignStmt asgn | 
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
        and (node = API::moduleImport("wtforms").getMember("PasswordField").getAValueReachableFromSource()
            or node = API::moduleImport("flask_wtf").getMember("PasswordField").getAValueReachableFromSource())
        and exists(cls.getLocation().getFile().getRelativePath())
        and asgn = cls.getAStmt().(AssignStmt)
        and asgn.getValue().(Call).getFunc() = node.asExpr()
        and cls.getAMethod().getName().prefix(9 + asgn.getATarget().(Name).getId().length()) = "validate_" + asgn.getATarget().(Name).getId()
        and result = node)
}

DataFlow::Node customValidators() {
    exists(DataFlow::Node node, ControlFlowNode element | 
        (node = API::moduleImport("wtforms").getMember("PasswordField").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("flask_wtf").getMember("PasswordField").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("wtforms").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink()
            or node = API::moduleImport("flask_wtf").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink())
        and (element = node.asExpr().(List).getAnElt().getAFlowNode()
            or element = node.asExpr().(Tuple).getAnElt().getAFlowNode())
        and not element = API::moduleImport("wtforms").getMember("validators").getAMember().getReturn().getAValueReachableFromSource().asCfgNode()
        and result = node)
}

from DataFlow::Node passfield
where passfield = inlineCustomValidators()
    or passfield = customValidators()
select passfield, passfield.getLocation(), "Using a custom validator to check password strength"
