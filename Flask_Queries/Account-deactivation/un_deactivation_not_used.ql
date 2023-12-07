import python
import semmle.python.ApiGraphs

predicate defaultDeactivation() {
    exists (Class cls | 
        cls.getClassObject().getASuperType().getPyClass().getName() = "UserMixin"
        and (not exists(Function f | 
                cls.getAMethod() = f
                and f.getName() = "is_active")
            or exists(Function f | 
                cls.getAMethod() = f
                and f.getName() = "is_active"
                and f.getReturnNode().isLiteral())))
}

where exists(DataFlow::Node node | 
        (node = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("force").getAValueReachingSink()
            or node = API::moduleImport("flask_login").getMember("login_user").getParameter(3).getAValueReachingSink())
        and node.asExpr().(ImmutableLiteral).booleanValue() = false)
    or not exists(DataFlow::Node force | 
        force = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("force").getAValueReachingSink()
        or force = API::moduleImport("flask_login").getMember("login_user").getParameter(3).getAValueReachingSink())
    and defaultDeactivation()
select "Deactivation isn't handled, it's left as default"
