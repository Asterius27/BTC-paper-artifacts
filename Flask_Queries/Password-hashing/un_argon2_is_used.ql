import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("argon2").getMember("PasswordHasher").getReturn().getMember("hash").getAValueReachingSink()
select node, node.getLocation(), "Argon2 is being used"
