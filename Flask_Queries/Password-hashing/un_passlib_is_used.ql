import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("passlib").getMember("hash").getAMember().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getAMember().getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getAMember().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("hash").getAMember().getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getAMember().getAMember().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getAMember().getAMember().getMember("using").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getAMember().getAMember().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("handlers").getAMember().getAMember().getMember("using").getReturn().getMember("encrypt").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("context").getMember("CryptContext").getReturn().getMember("hash").getAValueReachableFromSource()
        or node = API::moduleImport("passlib").getMember("context").getMember("CryptContext").getReturn().getMember("encrypt").getAValueReachableFromSource())
    and exists(node.asCfgNode())
    and not node.asExpr() instanceof ImportMember
select node, node.getLocation(), "PassLib is being used"