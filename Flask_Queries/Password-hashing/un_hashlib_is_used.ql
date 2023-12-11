import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("hashlib").getAMember().getReturn().getAValueReachingSink()
select node, node.getLocation(), "Hashlib is being used"
