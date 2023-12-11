import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getAValueReachableFromSource()
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "Werkzeug is being used"
