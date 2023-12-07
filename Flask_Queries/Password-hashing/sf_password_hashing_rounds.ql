import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getKeywordParameter("rounds").getAValueReachingSink()
        or node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getParameter(1).getAValueReachingSink())
    and node.asExpr().(IntegerLiteral).getValue() < 12
select node.asExpr().(IntegerLiteral).getValue(), node.getLocation(), "Number of rounds is set to a value less than 12 (default number of rounds)"
