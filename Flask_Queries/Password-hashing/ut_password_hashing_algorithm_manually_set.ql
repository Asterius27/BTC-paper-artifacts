import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getKeywordParameter("prefix").getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getParameter(2).getAValueReachingSink())
select node, node.getLocation(), "Password hashing algorithm is manually set"
