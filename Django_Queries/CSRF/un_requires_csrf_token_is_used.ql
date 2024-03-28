import python
import semmle.python.ApiGraphs

from ControlFlowNode node
where node = API::moduleImport("django").getMember("views").getMember("decorators").getMember("csrf").getMember("requires_csrf_token").getAValueReachableFromSource().asCfgNode()
    and not node.isImportMember()
select node, node.getLocation(), "The application is using requires_csrf_token for certain views (works similarly to csrf_protect, but never rejects an incoming request)"
