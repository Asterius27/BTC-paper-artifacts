import python
import semmle.python.ApiGraphs

// TODO It only seems to support scrypt and pbkdf2

Class getPasswordForms() {
    exists(Class cls, API::Node node | 
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
        and ((node = API::moduleImport("wtforms").getMember("PasswordField")
                or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
            and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
        and result = cls)
}

class HashlibConfiguration extends DataFlow::Configuration {
    HashlibConfiguration() { this = "HashlibConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asCfgNode() = getPasswordForms().getClassObject().getACall()
        and exists(source.getLocation().getFile().getRelativePath())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(API::Node node | 
            node = API::moduleImport("hashlib").getAMember()
            and (node.getParameter(0).asSink().asExpr().(Attribute).getObject() = sink.asExpr()
                or node.getParameter(1).asSink().asExpr().(Attribute).getObject() = sink.asExpr()
                or node.getKeywordParameter("password").asSink().asExpr().(Attribute).getObject() = sink.asExpr()))
        and exists(sink.getLocation().getFile().getRelativePath())
    }
}

from DataFlow::Node source, DataFlow::Node sink, HashlibConfiguration config, Attribute attr, AssignStmt asgn, API::Node node
where config.hasFlow(source, sink)
    and attr.getObject() = sink.asExpr()
    and asgn = getPasswordForms().getAStmt().(AssignStmt)
    and attr.getName() = asgn.getATarget().toString()
    and (node = API::moduleImport("wtforms").getMember("PasswordField")
        or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
    and asgn.getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr()
select source, source.getLocation(), sink, sink.getLocation(), "Hashlib is being used to hash passwords"
