import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("passlib").getMember("hash").getMember("scrypt").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("scrypt").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("scrypt").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("scrypt").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("scrypt").getMember("scrypt").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("scrypt").getMember("scrypt").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("scrypt").getMember("scrypt").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("scrypt").getMember("scrypt").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource())
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "PassLib's scrypt hasher is being used"
