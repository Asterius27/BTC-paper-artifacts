import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getKeywordParameter("rounds").getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getParameter(1).getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getKeywordParameter("rounds").getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getParameter(1).getAValueReachingSink())
select node, node.getLocation(), "Number of rounds is manually set"
