import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("password_strength").getMember("PasswordStats").getAValueReachableFromSource()
        or node = API::moduleImport("password_strength").getMember("PasswordPolicy").getAValueReachableFromSource())
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
select node, node.getLocation(), "password-strength is being used"
