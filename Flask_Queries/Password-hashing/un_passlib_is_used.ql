import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("passlib").getMember("hash").getAMember().getMember("hash").getAValueReachableFromSource()
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "PassLib is being used"
