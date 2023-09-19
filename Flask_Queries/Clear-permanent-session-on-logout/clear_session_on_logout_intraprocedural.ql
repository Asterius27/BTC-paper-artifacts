import python
import semmle.python.ApiGraphs

// TODO might want to check if session cookies are disabled as part of the query
// TODO maybe also check that session.clear() is called?
// This query isn't that useful, if the developer doesn't remove the permanent key then it might remain and be used in the next session
// It basically just checks that the developer correctly cleans up the session upon logout
DataFlow::Node inv() {
    exists(DataFlow::Node invalidate, DataFlow::ExprNode source | 
        invalidate = API::moduleImport("flask").getMember("session").getMember("pop").getParameter(0).asSink()
        and source.asExpr().(StrConst).getText().matches("\\_permanent")
        and DataFlow::localFlow(source, invalidate)
        and result = invalidate)
}

predicate aux(DataFlow::Node logout) {
    if exists(inv())
    then not inv().asCfgNode().strictlyReaches(logout.asCfgNode())
    else any()
}

from DataFlow::Node logout
where exists(DataFlow::Node perma, DataFlow::ExprNode source | 
        perma = API::moduleImport("flask").getMember("session").getMember("permanent").asSink()
        and source.asExpr().(ImmutableLiteral).booleanValue() = true
        and DataFlow::localFlow(source, perma)
        and exists(perma.getLocation().getFile().getRelativePath()))
    and logout = API::moduleImport("flask_login").getMember("logout_user").getACall()
    and exists(logout.getLocation().getFile().getRelativePath())
    and aux(logout)
select "Session cookie is set to permanent and isn't invalidated upon logout"
