import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

class FormConfiguration extends DataFlow::Configuration {
    FormConfiguration() { this = "FormConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(Class cls, API::Node node, AssignStmt asgn, Call call | 
            exists(cls.getLocation().getFile().getRelativePath())
            and (cls.getABase().toString() = "Form"
                or cls.getABase().toString() = "BaseForm"
                or cls.getABase().toString() = "FlaskForm")
            and (node = API::moduleImport("wtforms").getMember("PasswordField")
                or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
            and asgn = cls.getAStmt().(AssignStmt)
            and asgn.getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr()
            and call = asgn.getValue().(Call)
            and (exists(call.getPositionalArg(1))
                or call.getANamedArgumentName() = "validators"
                or cls.getAMethod().getName().prefix(9 + asgn.getATarget().(Name).getId().length()) = "validate_" + asgn.getATarget().(Name).getId())
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
    exists(Class cls, API::Node node, AssignStmt asgn, Call call | 
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
        and (node = API::moduleImport("wtforms").getMember("PasswordField")
            or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
        and asgn = cls.getAStmt().(AssignStmt)
        and asgn.getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr()
        and call = asgn.getValue().(Call)
        and (exists(call.getPositionalArg(1))
            or call.getANamedArgumentName() = "validators"
            or cls.getAMethod().getName().prefix(9 + asgn.getATarget().(Name).getId().length()) = "validate_" + asgn.getATarget().(Name).getId())
        and result = cls)
}

predicate formIsValidated(Class c) {
    exists(DataFlow::Node source, DataFlow::Node sink, FormConfiguration config |
        config.hasFlow(source, sink)
        and source.asCfgNode() = c.getClassObject().getACall())
}

from Class cls
where cls = getFormClasses()
    and exists(cls.getClassObject().getACall())
    and not formIsValidated(cls)
    and cls = FlaskLogin::getSignUpFormClass()
select cls, cls.getLocation(), "This form with a password field (that has some validators) is never validated"
