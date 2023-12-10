import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("wtforms").getMember("Form").getAValueReachableFromSource()
    or node = API::moduleImport("wtforms").getMember("BaseForm").getAValueReachableFromSource())
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
select node, node.getLocation(), "WTForms is being used"
