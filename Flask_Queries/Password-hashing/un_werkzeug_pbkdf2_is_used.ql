import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getKeywordParameter("method").getAValueReachingSink()
        or node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getParameter(1).getAValueReachingSink())
    and exists(node.asCfgNode())
    and node.asExpr().(StrConst).getS().prefix(6) = "pbkdf2"
select node, node.getLocation(), "Werkzeug's pbkdf2 hasher is being used"
