import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("passlib").getMember("hash").getAMember().getMember("hash").getAValueReachingSink()
select node, node.getLocation(), "PassLib is being used"
