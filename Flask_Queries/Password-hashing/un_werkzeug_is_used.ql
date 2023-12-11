import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getAValueReachingSink()
select node, node.getLocation(), "Werkzeug is being used"
