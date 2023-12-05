import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("force").getAValueReachingSink()
        or node = API::moduleImport("flask_login").getMember("login_user").getParameter(3).getAValueReachingSink())
    and node.asExpr().(ImmutableLiteral).booleanValue() = true
select node, node.getLocation(), "Deactivated users are allowed to log in"
