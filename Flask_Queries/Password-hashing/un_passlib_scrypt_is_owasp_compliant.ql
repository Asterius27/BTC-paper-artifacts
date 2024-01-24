import python
import semmle.python.ApiGraphs

API::Node libraryIsUsed() {
    exists(API::Node node |
        (node = API::moduleImport("passlib").getMember("hash").getMember("scrypt")
            or node = API::moduleImport("passlib").getMember("hash").getMember("scrypt").getMember("using"))
        and exists(node.getMember("hash").getAValueReachableFromSource().asCfgNode())
        and not node.getMember("hash").getAValueReachableFromSource().asExpr() instanceof ImportMember
        and result = node)
}

predicate memoryConfiguration(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getKeywordParameter("rounds").getAValueReachingSink()
            or param = node.getMember("rounds").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 17) // owasp recommendation minimum
    or not exists(DataFlow::Node param |
        (param = node.getKeywordParameter("rounds").getAValueReachingSink()
            or param = node.getMember("rounds").getAValueReachingSink()))
}

predicate blockSize(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getParameter(0).getAValueReachingSink()
            or param = node.getKeywordParameter("block_size").getAValueReachingSink()
            or param = node.getMember("block_size").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 8) // owasp recommendation minimum
}

predicate degreeOfParallelism(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getKeywordParameter("parallelism").getAValueReachingSink()
            or param = node.getMember("parallelism").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 1) // owasp recommendation minimum
}

from API::Node node
where node = libraryIsUsed()
    and not memoryConfiguration(node)
    and not blockSize(node)
    and not degreeOfParallelism(node)
select node.getMember("hash").getAValueReachableFromSource(), node.getMember("hash").getAValueReachableFromSource().getLocation(), "PassLib is being used with scrypt and it's compliant with owasp guidelines"
