import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_login").getMember("login_user").getAValueReachableFromSource()
        or node = API::moduleImport("flask_login").getMember("utils").getMember("login_user").getAValueReachableFromSource())
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
    and exists(node.getLocation().getFile().getRelativePath())
select "The flask-login library is actually used", node.getLocation()