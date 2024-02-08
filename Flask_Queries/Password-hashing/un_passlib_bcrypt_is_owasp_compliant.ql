import python
import semmle.python.ApiGraphs
import CodeQL_Library.Passlib

// TODO fix this query
predicate workFactor(API::Node node) {
    exists(DataFlow::Node param |
        param = node.getKeywordParameter("rounds").getAValueReachingSink()
        and param.asExpr().(IntegerLiteral).getValue() < 10) // owasp recommendation minimum
}

string outputs() {
    exists(DataFlow::Node hash, API::Node node |
        ((node = PassLib::getCustomUsingNode("bcrypt")
                and not workFactor(node)
                and hash = node.getReturn().getMember("hash").getAValueReachableFromSource())
            or hash = PassLib::getDefaultUsageNode("bcrypt"))
        and result = hash.toString() + ", " + hash.getLocation().toString() + ", PassLib is being used with bcrypt and it's compliant with owasp guidelines, however it doesn't handle passwords that are longer than 72 bytes, so should also check that there is a limit on the password length (by looking at the password strength length checks queries)")
}

string outputl() {
    exists(DataFlow::Node hash, API::Node node |
        ((node = PassLib::getCustomUsingNode("bcrypt_sha256")
                and not workFactor(node)
                and hash = node.getReturn().getMember("hash").getAValueReachableFromSource())
            or hash = PassLib::getDefaultUsageNode("bcrypt_sha256"))
        and result = hash.toString() + ", " + hash.getLocation().toString() + ", PassLib is being used with bcrypt, it's compliant with owasp guidelines and it's set to handle passwords that are longer than 72 bytes")
}

string output() {
    if exists(outputs())
    then if exists(outputl())
        then result = outputs() + "; " + outputl()
        else result = outputs()
    else if exists(outputl())
        then result = outputl()
        else none()
}

select output()
