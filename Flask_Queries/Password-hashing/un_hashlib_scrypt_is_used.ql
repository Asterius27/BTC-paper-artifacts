import python
import semmle.python.ApiGraphs

from ControlFlowNode node
where node = API::moduleImport("hashlib").getMember("scrypt").getReturn().getAValueReachableFromSource().asCfgNode()
    and (exists(node.(CallNode).getArg(0))
        or exists(node.(CallNode).getArgByName("password")))
    and not node.isImportMember()
select node, node.getLocation(), "Hashlib scrypt is being used to hash passwords"
