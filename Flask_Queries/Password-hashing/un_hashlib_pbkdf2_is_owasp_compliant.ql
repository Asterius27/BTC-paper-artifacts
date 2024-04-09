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

from ControlFlowNode node, StrConst method, IntegerLiteral iterations
where node = API::moduleImport("hashlib").getMember("pbkdf2_hmac").getReturn().getAValueReachableFromSource().asCfgNode()
    and (exists(node.(CallNode).getArg(1))
        or exists(node.(CallNode).getArgByName("password")))
    and not node.isImportMember()
    and (method.getAFlowNode() = node.(CallNode).getArg(0)
        or method.getAFlowNode() = node.(CallNode).getArgByName("hash_name"))
    and (iterations.getAFlowNode() = node.(CallNode).getArg(3)
        or iterations.getAFlowNode() = node.(CallNode).getArgByName("iterations"))
    and isCompliant(method.getText(), iterations.getValue())
select node, node.getLocation(), "Hashlib PBKDF2 is being used to hash passwords and it's owasp compliant"
