import python
import semmle.python.ApiGraphs
import CodeQL_Library.Passlib

predicate memoryConfiguration(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getParameter(1).getAValueReachingSink()
            or param = node.getKeywordParameter("memory_cost").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 19456) // 19 MiB (owasp recommendation minimum)
}

predicate iterationCount(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getParameter(3).getAValueReachingSink()
            or param = node.getKeywordParameter("time_cost").getAValueReachingSink()
            or param = node.getKeywordParameter("rounds").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 2) // owasp recommendation minimum
}

predicate degreeOfParallelism(API::Node node) {
    exists(DataFlow::Node param |
        param = node.getKeywordParameter("parallelism").getAValueReachingSink()
        and param.asExpr().(IntegerLiteral).getValue() < 1) // owasp recommendation minimum
}

predicate argonType(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getParameter(0).getAValueReachingSink()
            or param = node.getKeywordParameter("type").getAValueReachingSink())
        and param.asExpr().(StrConst).getS() != "ID") // owasp recommendation
}

from DataFlow::Node hash
where exists(API::Node node | 
        node = PassLib::getCustomUsingNode("argon2")
        and not memoryConfiguration(node)
        and not iterationCount(node)
        and not degreeOfParallelism(node)
        and not argonType(node)
        and hash = node.getReturn().getMember("hash").getAValueReachableFromSource())
    or hash = PassLib::getDefaultUsageNode("argon2")
select hash, hash.getLocation(), "PassLib is being used with argon2 and it's compliant with owasp guidelines"
