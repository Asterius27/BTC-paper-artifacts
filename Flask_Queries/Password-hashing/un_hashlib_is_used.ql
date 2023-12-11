import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("hashlib").getAMember().getAValueReachableFromSource()
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
    and exists(node.getLocation().getFile().getRelativePath())
select node, node.getLocation(), "Hashlib is being used"
