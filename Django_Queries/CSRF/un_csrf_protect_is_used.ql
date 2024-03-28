import python
import semmle.python.ApiGraphs

from ControlFlowNode node
where node = API::moduleImport("django").getMember("views").getMember("decorators").getMember("csrf").getMember("csrf_protect").getAValueReachableFromSource().asCfgNode()
    and not node.isImportMember()
select node, node.getLocation(), "The application is enabling csrf protection for certain views"
