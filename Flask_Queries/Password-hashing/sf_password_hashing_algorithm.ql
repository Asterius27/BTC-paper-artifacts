import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getKeywordParameter("prefix").getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getParameter(2).getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getKeywordParameter("prefix").getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getParameter(2).getAValueReachingSink())
    and node.asExpr().(StrConst).getS() != "2b"
select node.asExpr().(StrConst).getS(), node.getLocation(), "Using a bugged password hashing algorithm"
