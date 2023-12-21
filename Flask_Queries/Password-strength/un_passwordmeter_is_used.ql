import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("passwordmeter").getMember("test").getAValueReachableFromSource()
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
select node, node.getLocation(), "passwordmeter is being used"
