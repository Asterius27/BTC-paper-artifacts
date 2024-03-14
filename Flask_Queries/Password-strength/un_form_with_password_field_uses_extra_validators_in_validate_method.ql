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
                and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
            and source.asCfgNode() = cls.getClassObject().getACall())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(Attribute atr, AssignStmt asgn | 
            exists(atr.getLocation().getFile().getRelativePath())
            and (atr.getName() = "validate"
                or atr.getName() = "validate_on_submit")
            and exists(Call c | 
                exists(c.getLocation().getFile().getRelativePath())
                and atr.getAFlowNode() = c.getFunc().getAFlowNode()
                and (exists(c.getNamedArg(0))
                    or exists(c.getPositionalArg(0))))
            and asgn.getATarget().(Name).getVariable() = atr.getObject().(Name).getVariable()
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode())
    }
}

from DataFlow::Node source, DataFlow::Node sink, FormConfiguration config
where config.hasFlow(source, sink)
select sink, sink.getLocation(), "This form has a password field and passes extra validators when calling the validate or validate_on_submit method"
