import python
import semmle.python.ApiGraphs

from ControlFlowNode node
where (node = API::moduleImport("hashlib").getMember("pbkdf2_hmac").getReturn().getAValueReachableFromSource().asCfgNode()
        or node = API::moduleImport("hashlib").getMember("scrypt").getReturn().getAValueReachableFromSource().asCfgNode())
    and (exists(node.(CallNode).getArg(0))
        or exists(node.(CallNode).getArg(1))
        or exists(node.(CallNode).getArgByName("password")))
    and not node.isImportMember()
select node, node.getLocation(), "Hashlib is being used to hash passwords"
