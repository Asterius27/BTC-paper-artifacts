import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getAValueReachableFromSource()
        or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getAValueReachableFromSource())
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "Flask-Bcrypt is being used"
