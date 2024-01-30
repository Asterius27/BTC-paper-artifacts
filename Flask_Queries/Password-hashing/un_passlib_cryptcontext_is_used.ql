import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("passlib").getMember("context").getMember("CryptContext").getReturn().getMember("hash").getAValueReachableFromSource()
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "PassLib's CryptContext is being used"
