import python
import semmle.python.ApiGraphs

predicate inlineCustomValidators() {
    exists(Class cls | 
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
        and cls.getAMethod().getName().prefix(9) = "validate_")
}

predicate customValidators() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("wtforms").getMember("PasswordField").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("wtforms").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink())
        and exists(ControlFlowNode element | 
            element = node.asExpr().(List).getAnElt().getAFlowNode() | 
            forall(API::Node validator | 
                validator = API::moduleImport("wtforms").getMember("validators").getAMember() |
                validator.getReturn().getAValueReachableFromSource().asCfgNode() != element)))
}

where customValidators() or inlineCustomValidators()
select "Using a custom validator to check password strength"
