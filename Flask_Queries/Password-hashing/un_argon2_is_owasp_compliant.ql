import python
import semmle.python.ApiGraphs

DataFlow::Node libraryIsUsed() {
    exists(DataFlow::Node node |
        node = API::moduleImport("argon2").getMember("PasswordHasher").getReturn().getMember("hash").getAValueReachableFromSource()
        and exists(node.asCfgNode())
        and not node.asExpr() instanceof ImportMember
        and result = node)
}

predicate memoryConfiguration() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("argon2").getMember("PasswordHasher").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("argon2").getMember("PasswordHasher").getKeywordParameter("memory_cost").getAValueReachingSink())
        and node.asExpr().(IntegerLiteral).getValue() < 19456) // 19 MiB (owasp recommendation minimum)
}

predicate iterationCount() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("argon2").getMember("PasswordHasher").getParameter(0).getAValueReachingSink()
            or node = API::moduleImport("argon2").getMember("PasswordHasher").getKeywordParameter("time_cost").getAValueReachingSink())
        and node.asExpr().(IntegerLiteral).getValue() < 2) // owasp recommendation minimum
}

predicate degreeOfParallelism() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("argon2").getMember("PasswordHasher").getParameter(2).getAValueReachingSink()
            or node = API::moduleImport("argon2").getMember("PasswordHasher").getKeywordParameter("parallelism").getAValueReachingSink())
        and node.asExpr().(IntegerLiteral).getValue() < 1) // owasp recommendation minimum
}

predicate argonType() {
    exists(DataFlow::Node node, DataFlow::Node type | 
        (node = API::moduleImport("argon2").getMember("PasswordHasher").getParameter(6).getAValueReachingSink()
            or node = API::moduleImport("argon2").getMember("PasswordHasher").getKeywordParameter("type").getAValueReachingSink())
        and type = API::moduleImport("argon2").getMember("Type").getMember("ID").getAValueReachableFromSource()
        and node = type) // owasp recommended type
    or not exists(DataFlow::Node node | 
        (node = API::moduleImport("argon2").getMember("PasswordHasher").getParameter(6).getAValueReachingSink()
            or node = API::moduleImport("argon2").getMember("PasswordHasher").getKeywordParameter("type").getAValueReachingSink()))
}

from DataFlow::Node node
where node = libraryIsUsed()
    and not memoryConfiguration()
    and not iterationCount()
    and not degreeOfParallelism()
    and argonType()
select node, node.getLocation(), "Argon2 is being used and it's compliant with owasp guidelines"
