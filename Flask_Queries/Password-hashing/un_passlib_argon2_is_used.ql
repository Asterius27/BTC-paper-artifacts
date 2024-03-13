import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("passlib").getMember("hash").getMember("argon2").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("argon2").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("argon2").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("argon2").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("argon2").getMember("argon2").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("argon2").getMember("argon2").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("argon2").getMember("argon2").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("argon2").getMember("argon2").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource())
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "PassLib's argon2 hasher is being used"
