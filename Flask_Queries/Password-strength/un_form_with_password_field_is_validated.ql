import python
import semmle.python.ApiGraphs

class FormConfiguration extends DataFlow::Configuration {
    FormConfiguration() { this = "FormConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(Class cls | 
            exists(cls.getLocation().getFile().getRelativePath())
            and (cls.getABase().toString() = "Form"
                or cls.getABase().toString() = "BaseForm"
                or cls.getABase().toString() = "FlaskForm")
            and exists(API::Node node | 
                (node = API::moduleImport("wtforms").getMember("PasswordField")
                    or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
                and (exists(node.getParameter(1).getAValueReachingSink())
                    or exists(node.getKeywordParameter("validators").getAValueReachingSink())
                    or cls.getAMethod().getName().prefix(9) = "validate_")
                and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
            and source.asCfgNode() = cls.getClassObject().getACall())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(Attribute atr, AssignStmt asgn | 
            exists(atr.getLocation().getFile().getRelativePath())
            and (atr.getName() = "validate"
                or atr.getName() = "validate_on_submit")
            and asgn.getATarget().(Name).getVariable() = atr.getObject().(Name).getVariable()
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode())
    }
}

Class getFormClasses() {
    exists(Class cls | 
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
        and exists(API::Node node | 
            (node = API::moduleImport("wtforms").getMember("PasswordField")
                or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
            and (exists(node.getParameter(1).getAValueReachingSink())
                or exists(node.getKeywordParameter("validators").getAValueReachingSink())
                or cls.getAMethod().getName().prefix(9) = "validate_")
            and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
        and result = cls)
}

from DataFlow::Node source
where not exists(DataFlow::Node sink, FormConfiguration config |
    config.hasFlow(source, sink))
    and source.asCfgNode() = getFormClasses().getClassObject().getACall()
select source, source.getLocation(), "This form with a password field (that has some validators) is never validated"
