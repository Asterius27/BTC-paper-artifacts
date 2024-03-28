import python
import semmle.python.ApiGraphs

from ControlFlowNode node
where node = API::moduleImport("django").getMember("views").getMember("decorators").getMember("csrf").getMember("ensure_csrf_cookie").getAValueReachableFromSource().asCfgNode()
    and not node.isImportMember()
select node, node.getLocation(), "The application is forcing certain views to send the CSRF cookie"
