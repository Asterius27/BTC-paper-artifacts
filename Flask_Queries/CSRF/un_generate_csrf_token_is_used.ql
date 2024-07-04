import python
import semmle.python.ApiGraphs

from ControlFlowNode node
where (node = API::moduleImport("flask_wtf").getMember("csrf").getMember("generate_csrf").getACall().asCfgNode()
        or node = API::moduleImport("flask_wtf").getMember("generate_csrf").getACall().asCfgNode())
    and not node.isImportMember()
select node, node.getLocation(), "Using Flask-WTF generate csrf token"
