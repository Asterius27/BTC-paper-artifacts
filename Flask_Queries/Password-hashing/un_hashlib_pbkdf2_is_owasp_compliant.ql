import python
import semmle.python.ApiGraphs

bindingset[method, iterations]
predicate isCompliant(string method, int iterations) {
    (method = "sha256"
        and iterations >= 600000)
    or (method = "sha512"
        and iterations >= 210000)
    or (method = "sha1"
        and iterations >= 1300000)
}

from API::Node node, StrConst method, IntegerLiteral iterations
where node = API::moduleImport("hashlib").getMember("pbkdf2_hmac")
    and (exists(node.getParameter(1))
        or exists(node.getKeywordParameter("password")))
    and (method = node.getParameter(0).getAValueReachingSink().asExpr().(StrConst)
        or method = node.getKeywordParameter("hash_name").getAValueReachingSink().asExpr().(StrConst))
    and (iterations = node.getParameter(3).getAValueReachingSink().asExpr().(IntegerLiteral)
        or iterations = node.getKeywordParameter("iterations").getAValueReachingSink().asExpr().(IntegerLiteral))
    and isCompliant(method.getS(), iterations.getValue())
select node, node.getAValueReachableFromSource().getLocation(), "Hashlib PBKDF2 is being used to hash passwords and it's owasp compliant"
