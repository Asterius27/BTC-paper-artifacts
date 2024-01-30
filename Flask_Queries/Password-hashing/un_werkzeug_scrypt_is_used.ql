import python
import semmle.python.ApiGraphs

from API::Node node
where node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash")
    and (exists(DataFlow::Node method |
            (method = node.getKeywordParameter("method").getAValueReachingSink()
                or method = node.getParameter(1).getAValueReachingSink())
            and method.asExpr().(StrConst).getS().prefix(6) = "scrypt")
        or not exists(DataFlow::Node method | 
            (method = node.getKeywordParameter("method").getAValueReachingSink()
                or method = node.getParameter(1).getAValueReachingSink())))
select node.getAValueReachableFromSource(), node.getAValueReachableFromSource().getLocation(), "Werkzeug's scrypt hasher is being used"
