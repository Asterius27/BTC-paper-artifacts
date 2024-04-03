import python
import semmle.python.ApiGraphs

bindingset[n, r, p]
predicate isCompliant(int n, int r, int p) {
    n >= 131072 and r >= 8 and p >= 1
}

from API::Node node, IntegerLiteral n, IntegerLiteral r, IntegerLiteral p
where node = API::moduleImport("hashlib").getMember("scrypt")
    and (exists(node.getParameter(0))
        or exists(node.getKeywordParameter("password")))
    and n = node.getKeywordParameter("n").getAValueReachingSink().asExpr().(IntegerLiteral)
    and r = node.getKeywordParameter("r").getAValueReachingSink().asExpr().(IntegerLiteral)
    and p = node.getKeywordParameter("p").getAValueReachingSink().asExpr().(IntegerLiteral)
    and isCompliant(n.getValue(), r.getValue(), p.getValue())
select node, node.getAValueReachableFromSource().getLocation(), "Hashlib scrypt is being used to hash passwords and it's owasp compliant"
