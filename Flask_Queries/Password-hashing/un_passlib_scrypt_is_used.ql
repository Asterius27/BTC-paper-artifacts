import python
import semmle.python.ApiGraphs

// TODO have to fix every passlib query, need to check if getReturn() is present where needed in the other passlib queries

from DataFlow::Node node
where (node = API::moduleImport("passlib").getMember("hash").getMember("scrypt").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("scrypt").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource())
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "PassLib's scrypt hasher is being used"
