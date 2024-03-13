import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

DataFlow::Node libraryIsUsed() {
    exists(DataFlow::Node node | 
        (node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getAValueReachableFromSource()
            or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getAValueReachableFromSource())
        and exists(node.asCfgNode())
        and not node.asExpr() instanceof ImportMember
        and result = node)
}

predicate workFactor() {
    exists(DataFlow::Node node |
        (node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getKeywordParameter("rounds").getAValueReachingSink()
            or node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn().getMember("generate_password_hash").getParameter(1).getAValueReachingSink()
            or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getKeywordParameter("rounds").getAValueReachingSink()
            or node = API::moduleImport("flask_bcrypt").getMember("generate_password_hash").getParameter(1).getAValueReachingSink())
        and node.asExpr().(IntegerLiteral).getValue() < 10) // owasp recommendation minimum
    or exists(Expr expr | 
        expr = FlaskLogin::getConfigValue("BCRYPT_LOG_ROUNDS")
        and expr.(IntegerLiteral).getValue() < 10) // owasp recommendation minimum
}

predicate length() {
    exists(Expr expr | 
        expr = FlaskLogin::getConfigValue("BCRYPT_HANDLE_LONG_PASSWORDS")
        and expr.(ImmutableLiteral).booleanValue() = true)
}

string output() {
    if length()
    then result = "Flask-Bcrypt is being used, it's compliant with owasp guidelines and it's set to handle passwords that are longer than 72 bytes"
    else result = "Flask-Bcrypt is being used and it's compliant with owasp guidelines, however it doesn't handle passwords that are longer than 72 bytes, so should also check that there is a limit on the password length (by looking at the password strength length checks queries)"
}

from DataFlow::Node node
where node = libraryIsUsed()
    and not workFactor()
select node, node.getLocation(), output()
