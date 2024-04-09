import python
import semmle.python.ApiGraphs

from ControlFlowNode node
where node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getReturn().getAValueReachableFromSource().asCfgNode()
    and (exists(StrConst method |
            (method.getAFlowNode() = node.(CallNode).getArgByName("method")
                or method.getAFlowNode() = node.(CallNode).getArg(1))
            and method.getText().prefix(6) = "scrypt")
        or not exists(ControlFlowNode method | 
            (method = node.(CallNode).getArgByName("method")
                or method = node.(CallNode).getArg(1))))
    and not node.isImportMember()
select node, node.getLocation(), "Werkzeug's scrypt hasher is being used"
