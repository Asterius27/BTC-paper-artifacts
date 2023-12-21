import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("deform").getMember("Form").getAValueReachableFromSource()
    or node = API::moduleImport("deform").getMember("schema").getMember("CSRFSchema").getAValueReachableFromSource())
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
select node, node.getLocation(), "Deform is being used"
