import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

// TODO might want to check if session cookies are disabled as part of the query
Expr getConfigNode() {
    exists(Expr expr | 
        expr = FlaskLogin::getConfigValue("PERMANENT_SESSION_LIFETIME", "permanent_session_lifetime")
        and result = expr)
}

string output() {
    if exists(getConfigNode())
    then result = getConfigNode().getLocation().toString() + ", Session is set to permanent and session cookie duration is manually set"
    else result = "Session is set to permanent but session cookie duration is not manually set"
}

where exists(DataFlow::Node perma | 
    perma = API::moduleImport("flask").getMember("session").getMember("permanent").getAValueReachingSink()
    and perma.asExpr().(ImmutableLiteral).booleanValue() = true
    and exists(perma.getLocation().getFile().getRelativePath()))
select output()
