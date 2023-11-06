import python
import CodeQL_Library.InterproceduralControlFlow
import semmle.python.ApiGraphs

// TODO might want to check if session cookies are disabled as part of the query
// This checks that session.clear() is called, since if the developer adds stuff to the session cookie (using session["..."] = ...), the cookie doesn't get deleted and that stuff remains in the cookie. (only the _user_id, _fresh, _id, _remember fields get deleted)
// The session cookie gets deleted only if the session dictionary (session["..."]) is empty
// It basically just checks that the developer correctly cleans up the session upon logout
predicate aux(DataFlow::Node logout) {
    exists(API::moduleImport("flask").getMember("session").getASubscript().getAValueReachingSink())
    and exists(DataFlow::Node invalidate | 
        invalidate = API::moduleImport("flask").getMember("session").getMember("clear").getAValueReachableFromSource()
        and exists(invalidate.getLocation().getFile().getRelativePath())
        and exists(invalidate.asCfgNode())
        and not InterproceduralControlFlow::reaches(invalidate.asCfgNode(), logout.asCfgNode()))
}

/* Old version
predicate aux(DataFlow::Node logout) {
    if API::moduleImport("flask").getMember("session").getMember("pop").getParameter(0).getAValueReachingSink().asExpr().(StrConst).getText().matches("\\_permanent")
    then exists (DataFlow::Node invalidate | 
        invalidate = API::moduleImport("flask").getMember("session").getMember("pop").getParameter(0).getAValueReachingSink()
        and invalidate.asExpr().(StrConst).getText() = "_permanent"
        and exists(invalidate.getLocation().getFile().getRelativePath()) 
        and not reaches(invalidate.asCfgNode(), logout.asCfgNode()))
    else any()
}
*/

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
select logout.getLocation(), "Session cookie is set to permanent and isn't invalidated upon logout"

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
