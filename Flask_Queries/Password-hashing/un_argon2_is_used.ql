import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("argon2").getMember("PasswordHasher").getReturn().getMember("hash").getAValueReachableFromSource()
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "Argon2 is being used"
