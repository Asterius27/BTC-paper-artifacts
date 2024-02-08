import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("hashers").getMember("make_password").getAValueReachableFromSource()
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
    and exists(node.getLocation().getFile().getRelativePath())
select node.getLocation(), "Django's password hashing is actually used"
