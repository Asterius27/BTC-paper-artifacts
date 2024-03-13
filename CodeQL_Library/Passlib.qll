import python
import semmle.python.ApiGraphs

module PassLib {
    DataFlow::Node getDefaultUsageNode(string alg) {
        exists(DataFlow::Node node | 
            (node = API::moduleImport("passlib").getMember("hash").getMember(alg).getMember("hash").getAValueReachableFromSource()
                or node = API::moduleImport("passlib").getMember("hash").getMember(alg).getMember("encrypt").getAValueReachableFromSource()
                or node = API::moduleImport("passlib").getMember("handlers").getMember(alg.splitAt("_", 0)).getMember(alg).getMember("hash").getAValueReachableFromSource()
                or node = API::moduleImport("passlib").getMember("handlers").getMember(alg.splitAt("_", 0)).getMember(alg).getMember("encrypt").getAValueReachableFromSource()
                or node = API::moduleImport("passlib").getMember("handlers").getMember(alg).getMember(alg).getMember("hash").getAValueReachableFromSource()
                or node = API::moduleImport("passlib").getMember("handlers").getMember(alg).getMember(alg).getMember("encrypt").getAValueReachableFromSource())
            and exists(node.asCfgNode())
            and not node.asExpr() instanceof ImportMember
            and result = node)
    }

    API::Node getCustomUsingNode(string alg) {
        exists(API::Node node |
            (node = API::moduleImport("passlib").getMember("hash").getMember(alg).getMember("using")
                or node = API::moduleImport("passlib").getMember("handlers").getMember(alg.splitAt("_", 0)).getMember(alg).getMember("using")
                or node = API::moduleImport("passlib").getMember("handlers").getMember(alg).getMember(alg).getMember("using"))
            and ((exists(node.getReturn().getMember("hash").getAValueReachableFromSource().asCfgNode())
                    and not node.getReturn().getMember("hash").getAValueReachableFromSource().asExpr() instanceof ImportMember)
                or (exists(node.getReturn().getMember("encrypt").getAValueReachableFromSource().asCfgNode())
                    and not node.getReturn().getMember("encrypt").getAValueReachableFromSource().asExpr() instanceof ImportMember))
            and result = node)
    }
}