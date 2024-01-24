import python
import semmle.python.ApiGraphs

DataFlow::Node libraryIsUsed() {
    exists(DataFlow::Node node | 
        node = API::moduleImport("bcrypt").getMember("hashpw").getAValueReachableFromSource()
        and exists(node.asCfgNode())
        and not node.asExpr() instanceof ImportMember
        and result = node)
}

predicate workFactor() {
    exists(DataFlow::Node node |
        (node = API::moduleImport("bcrypt").getMember("gensalt").getParameter(0).getAValueReachableFromSource()
            or node = API::moduleImport("bcrypt").getMember("gensalt").getKeywordParameter("rounds").getAValueReachableFromSource())
        and node.asExpr().(IntegerLiteral).getValue() < 10) // owasp recommendation minimum
}

from DataFlow::Node node
where node = libraryIsUsed()
    and not workFactor()
select node, node.getLocation(), "Bcrypt is being used, it's compliant with owasp guidelines, but it doesn't handle passwords that are longer than 72 bytes, so should also check that there is a limit on the password length (by looking at the password strength length checks queries)"
