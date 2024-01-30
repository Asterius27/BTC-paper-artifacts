import python
import semmle.python.ApiGraphs
import CodeQL_Library.Passlib

predicate memoryConfiguration(API::Node node) {
    exists(DataFlow::Node param |
        param = node.getKeywordParameter("rounds").getAValueReachingSink()
        and param.asExpr().(IntegerLiteral).getValue() < 17) // owasp recommendation minimum
    or not exists(DataFlow::Node param |
        param = node.getKeywordParameter("rounds").getAValueReachingSink())
}

predicate blockSize(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getParameter(0).getAValueReachingSink()
            or param = node.getKeywordParameter("block_size").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 8) // owasp recommendation minimum
}

predicate degreeOfParallelism(API::Node node) {
    exists(DataFlow::Node param |
        param = node.getKeywordParameter("parallelism").getAValueReachingSink()
        and param.asExpr().(IntegerLiteral).getValue() < 1) // owasp recommendation minimum
}

from API::Node node
where node = PassLib::getCustomUsingNode("scrypt")
    and not memoryConfiguration(node)
    and not blockSize(node)
    and not degreeOfParallelism(node)
    and not exists(PassLib::getDefaultUsageNode("scrypt"))
select node.getReturn().getMember("hash").getAValueReachableFromSource(), node.getReturn().getMember("hash").getAValueReachableFromSource().getLocation(), "PassLib is being used with scrypt and it's compliant with owasp guidelines"
