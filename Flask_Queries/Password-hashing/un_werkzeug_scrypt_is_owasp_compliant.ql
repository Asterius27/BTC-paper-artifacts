import python
import semmle.python.ApiGraphs

DataFlow::Node libraryIsUsed() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getKeywordParameter("method").getAValueReachingSink()
            or node =API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getParameter(1).getAValueReachingSink())
        and node.asExpr().(StrConst).getS().prefix(6) = "scrypt"
        and result = node)
}

bindingset[n, r, p]
predicate isCompliant(int n, int r, int p) {
    n >= 131072 and r >= 8 and p >= 1
}

predicate aux(DataFlow::Node node) {
    if exists(node.asExpr().(StrConst).getS().splitAt(":", 0)) and exists(node.asExpr().(StrConst).getS().splitAt(":", 1).toInt()) and exists(node.asExpr().(StrConst).getS().splitAt(":", 2).toInt()) and exists(node.asExpr().(StrConst).getS().splitAt(":", 3).toInt())
    then isCompliant(node.asExpr().(StrConst).getS().splitAt(":", 1).toInt(), node.asExpr().(StrConst).getS().splitAt(":", 2).toInt(), node.asExpr().(StrConst).getS().splitAt(":", 3).toInt())
    else none()
}

from DataFlow::Node node
where node = libraryIsUsed()
    and aux(node)
select node, node.getLocation(), "Werkzeug's scrypt hasher is being used and it's compliant with owasp guidelines"
