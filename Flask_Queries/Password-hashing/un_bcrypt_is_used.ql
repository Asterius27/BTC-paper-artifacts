import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("bcrypt").getMember("hashpw").getAValueReachableFromSource()
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "Bcrypt is being used"
