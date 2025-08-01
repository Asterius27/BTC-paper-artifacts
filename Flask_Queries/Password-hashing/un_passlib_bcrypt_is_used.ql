import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt_sha256").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt_sha256").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt_sha256").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getMember("bcrypt_sha256").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt_sha256").getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt_sha256").getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt_sha256").getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getMember("bcrypt").getMember("bcrypt_sha256").getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource())
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "PassLib's bcrypt hasher is being used"
