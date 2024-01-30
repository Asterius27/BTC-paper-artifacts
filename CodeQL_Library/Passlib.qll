import python
import semmle.python.ApiGraphs

module PassLib {
    DataFlow::Node getDefaultUsageNode(string alg) {
        exists(DataFlow::Node node | 
            node = API::moduleImport("passlib").getMember("hash").getMember(alg).getMember("hash").getAValueReachableFromSource()
            and exists(node.asCfgNode())
            and not node.asExpr() instanceof ImportMember
            and result = node)
    }

    API::Node getCustomUsingNode(string alg) {
        exists(API::Node node |
            node = API::moduleImport("passlib").getMember("hash").getMember(alg).getMember("using")
            and exists(node.getReturn().getMember("hash").getAValueReachableFromSource().asCfgNode())
            and not node.getReturn().getMember("hash").getAValueReachableFromSource().asExpr() instanceof ImportMember
            and result = node)
    }
}