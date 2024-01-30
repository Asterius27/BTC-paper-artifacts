import python
import semmle.python.ApiGraphs

DataFlow::Node libraryIsUsed() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getKeywordParameter("method").getAValueReachingSink()
            or node = API::moduleImport("werkzeug").getMember("security").getMember("generate_password_hash").getParameter(1).getAValueReachingSink())
        and exists(node.asCfgNode())
        and node.asExpr().(StrConst).getS().prefix(6) = "pbkdf2"
        and result = node)
}

bindingset[method, iterations]
predicate isCompliant(string method, int iterations) {
    (method = "sha256"
        and iterations >= 600000)
    or (method = "sha512"
        and iterations >= 210000)
}

predicate aux(DataFlow::Node node) {
    if exists(node.asExpr().(StrConst).getS().splitAt(":", 1)) and exists(node.asExpr().(StrConst).getS().splitAt(":", 2).toInt())
    then isCompliant(node.asExpr().(StrConst).getS().splitAt(":", 1), node.asExpr().(StrConst).getS().splitAt(":", 2).toInt())
    else if exists(node.asExpr().(StrConst).getS().splitAt(":", 1))
        then node.asExpr().(StrConst).getS().splitAt(":", 1) = "sha256" or node.asExpr().(StrConst).getS().splitAt(":", 1) = "sha512"
        else any()
}

from DataFlow::Node node
where node = libraryIsUsed()
    and aux(node)
select node, node.getLocation(), "Werkzeug's pbkdf2 hasher is being used and it's compliant with owasp guidelines"
