import python
import semmle.python.ApiGraphs

API::Node libraryIsUsed() {
    exists(API::Node node |
        (node = API::moduleImport("passlib").getMember("hash").getMember("argon2")
            or node = API::moduleImport("passlib").getMember("hash").getMember("argon2").getMember("using"))
        and exists(node.getMember("hash").getAValueReachableFromSource().asCfgNode())
        and not node.getMember("hash").getAValueReachableFromSource().asExpr() instanceof ImportMember
        and result = node)
}

predicate memoryConfiguration(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getParameter(3).getAValueReachingSink()
            or param = node.getKeywordParameter("memory_cost").getAValueReachingSink()
            or param = node.getMember("memory_cost").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 19456) // 19 MiB (owasp recommendation minimum)
}

predicate iterationCount(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getKeywordParameter("time_cost").getAValueReachingSink()
            or param = node.getMember("time_cost").getAValueReachingSink()
            or param = node.getKeywordParameter("rounds").getAValueReachingSink()
            or param = node.getMember("rounds").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 2) // owasp recommendation minimum
}

predicate degreeOfParallelism(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getKeywordParameter("parallelism").getAValueReachingSink()
            or param = node.getMember("parallelism").getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < 1) // owasp recommendation minimum
}

predicate argonType(API::Node node) {
    exists(DataFlow::Node param |
        (param = node.getParameter(0).getAValueReachingSink()
            or param = node.getKeywordParameter("type").getAValueReachingSink()
            or param = node.getMember("type").getAValueReachingSink())
        and param.asExpr().(StrConst).getS() != "ID") // owasp recommendation
}

from API::Node node
where node = libraryIsUsed()
    and not memoryConfiguration(node)
    and not iterationCount(node)
    and not degreeOfParallelism(node)
    and not argonType(node)
select node.getMember("hash").getAValueReachableFromSource(), node.getMember("hash").getAValueReachableFromSource().getLocation(), "PassLib is being used with argon2 and it's compliant with owasp guidelines"
