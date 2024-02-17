import python
import semmle.python.ApiGraphs

from DataFlow::Node auth, DataFlow::Node login
where auth = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("authenticate").getAValueReachableFromSource()
    and not auth.asExpr() instanceof ImportMember
    and exists(auth.asCfgNode())
    and exists(auth.getLocation().getFile().getRelativePath())
    and login = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("login").getAValueReachableFromSource()
    and not login.asExpr() instanceof ImportMember
    and exists(login.asCfgNode())
    and exists(login.getLocation().getFile().getRelativePath())
select auth, login, auth.getLocation(), login.getLocation(), "Both the authenticate and login functions are used"
