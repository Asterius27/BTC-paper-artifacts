import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("bcrypt").getMember("hashpw").getAValueReachingSink()
select node, node.getLocation(), "Bcrypt is being used"
