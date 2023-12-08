import python
import semmle.python.ApiGraphs

predicate defaultDeactivation() {
    exists (Class cls | 
        exists(cls.getLocation().getFile().getRelativePath())
        and cls.getABase().toString() = "UserMixin"
        and not exists(Function f | 
            cls.getAMethod() = f
            and f.getName() = "is_active"
            and f.getAReturnValueFlowNode().inferredValue().getABooleanValue() != true))
}

where (exists(DataFlow::Node node | 
        (node = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("force").getAValueReachingSink()
            or node = API::moduleImport("flask_login").getMember("login_user").getParameter(3).getAValueReachingSink())
        and node.asExpr().(ImmutableLiteral).booleanValue() = false)
    or not exists(DataFlow::Node force | 
        force = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("force").getAValueReachingSink()
        or force = API::moduleImport("flask_login").getMember("login_user").getParameter(3).getAValueReachingSink()))
    and defaultDeactivation()
select "Deactivation isn't handled, everything is left as default (deactivated users aren't allowed to log in, but all accounts are always active)"
