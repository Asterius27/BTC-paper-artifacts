import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_login").getMember("logout_user").getAValueReachableFromSource()
        or node = API::moduleImport("flask_login").getMember("utils").getMember("logout_user").getAValueReachableFromSource())
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
    and exists(node.getLocation().getFile().getRelativePath())
select "The logout function gets called at: ", node.getLocation()