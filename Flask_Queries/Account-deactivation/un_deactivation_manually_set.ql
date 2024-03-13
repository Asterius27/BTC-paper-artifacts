import python
import semmle.python.ApiGraphs

// TODO fix moduleImport("flask_login").getMember("utils")
from DataFlow::Node node
where (node = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("force").getAValueReachingSink()
        or node = API::moduleImport("flask_login").getMember("login_user").getParameter(3).getAValueReachingSink())
    and node.asExpr().(ImmutableLiteral).booleanValue() = false
select node, node.getLocation(), "Deactivated users are not allowed to log in (force is manually set to false and not left as default)"
