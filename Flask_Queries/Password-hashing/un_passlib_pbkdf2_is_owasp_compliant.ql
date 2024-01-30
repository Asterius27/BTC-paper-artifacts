import python
import semmle.python.ApiGraphs
import CodeQL_Library.Passlib

bindingset[rounds, keyword, pos]
predicate workFactor(API::Node node, int rounds, string keyword, int pos) {
    exists(DataFlow::Node param |
        (param = node.getKeywordParameter(keyword).getAValueReachingSink()
            or param = node.getParameter(pos).getAValueReachingSink())
        and param.asExpr().(IntegerLiteral).getValue() < rounds)
    or not exists(DataFlow::Node param |
        (param = node.getKeywordParameter(keyword).getAValueReachingSink()
            or param = node.getParameter(pos).getAValueReachingSink()))
}

from API::Node node
where (node = PassLib::getCustomUsingNode("pbkdf2_sha256")
        and (not workFactor(node, 600000, "rounds", 6) // owasp recommendation minimum
            or not workFactor(node, 600000, "min_desired_rounds", 0) // owasp recommendation minimum
            or not workFactor(node, 600000, "min_rounds", 4) // owasp recommendation minimum
            or not workFactor(node, 600000, "default_rounds", 2)) // owasp recommendation minimum
        and not exists(PassLib::getDefaultUsageNode("pbkdf2_sha256")))
    or (node = PassLib::getCustomUsingNode("pbkdf2_sha512")
        and (not workFactor(node, 210000, "rounds", 6) // owasp recommendation minimum
            or not workFactor(node, 210000, "min_desired_rounds", 0) // owasp recommendation minimum
            or not workFactor(node, 210000, "min_rounds", 4) // owasp recommendation minimum
            or not workFactor(node, 210000, "default_rounds", 2)) // owasp recommendation minimum
        and not exists(PassLib::getDefaultUsageNode("pbkdf2_sha512")))
select node.getReturn().getMember("hash").getAValueReachableFromSource(), node.getReturn().getMember("hash").getAValueReachableFromSource().getLocation(), "PassLib is being used with pbkdf2 and it's compliant with owasp guidelines"
