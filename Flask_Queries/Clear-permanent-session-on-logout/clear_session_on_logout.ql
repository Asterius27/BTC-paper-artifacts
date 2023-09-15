import python
import semmle.python.ApiGraphs

// TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query

// TODO this might lead to infite recursion, have to put a time limit (or something) when running this query
predicate reaches(ControlFlowNode source, ControlFlowNode sink) {
    source.strictlyReaches(sink)
    and exists(sink.getLocation().getFile().getRelativePath())
    and exists(source.getLocation().getFile().getRelativePath())
    or exists(Call c, Function f | 
        source.strictlyReaches(c.getAFlowNode())
        and c.getFunc().toString() = f.getName()
        and exists(c.getLocation().getFile().getRelativePath())
        and exists(f.getLocation().getFile().getRelativePath())
        and reaches(f.getAFlowNode(), sink))
}

predicate aux(DataFlow::Node logout) {
    if API::moduleImport("flask").getMember("session").getMember("pop").getParameter(0).getAValueReachingSink().asExpr().(StrConst).getText().matches("\\_permanent")
    then exists (DataFlow::Node invalidate | 
        invalidate = API::moduleImport("flask").getMember("session").getMember("pop").getParameter(0).getAValueReachingSink()
        and invalidate.asExpr().(StrConst).getText() = "_permanent"
        and exists(invalidate.getLocation().getFile().getRelativePath()) 
        and not reaches(invalidate.asCfgNode(), logout.asCfgNode()))
    else any()
}

from DataFlow::Node logout
where exists(DataFlow::Node perma | 
        perma = API::moduleImport("flask").getMember("session").getMember("permanent").getAValueReachingSink()
        and perma.asExpr().(ImmutableLiteral).booleanValue() = true
        and exists(perma.getLocation().getFile().getRelativePath()))
    and logout = API::moduleImport("flask_login").getMember("logout_user").getAValueReachableFromSource()
    and not logout.asExpr() instanceof ImportMember
    and exists(logout.asCfgNode())
    and exists(logout.getLocation().getFile().getRelativePath())
    and aux(logout)
select "Session cookie is set to permanent and isn't invalidated upon logout"

/* This works
from DataFlow::Node perma
where perma = API::moduleImport("flask").getMember("session").getMember("permanent").getAValueReachingSink()
    and perma.asExpr().(ImmutableLiteral).booleanValue() = true
    and exists(perma.getLocation().getFile().getRelativePath())
select perma, perma.getLocation()
*/

/* This works
from DataFlow::Node logout
where logout = API::moduleImport("flask_login").getMember("logout_user").getAValueReachableFromSource()
    and not logout.asExpr() instanceof ImportMember
    and exists(logout.asCfgNode())
    and exists(logout.getLocation().getFile().getRelativePath())
select logout, logout.getLocation()
*/

/* This works
from DataFlow::Node invalidate
where invalidate = API::moduleImport("flask").getMember("session").getMember("pop").getParameter(0).getAValueReachingSink()
    and invalidate.asExpr().(StrConst).getText() = "_permanent"
    and exists(invalidate.getLocation().getFile().getRelativePath())
select invalidate, invalidate.getLocation()
*/
