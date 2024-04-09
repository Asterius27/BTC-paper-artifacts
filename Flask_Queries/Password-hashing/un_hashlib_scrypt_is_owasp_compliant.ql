import python
import semmle.python.ApiGraphs

bindingset[n, r, p]
predicate isCompliant(int n, int r, int p) {
    n >= 131072 and r >= 8 and p >= 1
}

from ControlFlowNode node, IntegerLiteral n, IntegerLiteral r, IntegerLiteral p
where node = API::moduleImport("hashlib").getMember("scrypt").getReturn().getAValueReachableFromSource().asCfgNode()
    and (exists(node.(CallNode).getArg(0))
        or exists(node.(CallNode).getArgByName("password")))
    and not node.isImportMember()
    and n.getAFlowNode() = node.(CallNode).getArgByName("n")
    and r.getAFlowNode() = node.(CallNode).getArgByName("r")
    and p.getAFlowNode() = node.(CallNode).getArgByName("p")
    and isCompliant(n.getValue(), r.getValue(), p.getValue())
select node, node.getLocation(), "Hashlib scrypt is being used to hash passwords and it's owasp compliant"
