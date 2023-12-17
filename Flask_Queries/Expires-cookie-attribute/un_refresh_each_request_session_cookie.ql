import python
import CodeQL_Library.FlaskLogin

predicate valueCheck(Expr expr) {
    expr.(ImmutableLiteral).booleanValue() = true
}

where (exists(Expr expr | 
        expr = FlaskLogin::getConfigValue("SESSION_REFRESH_EACH_REQUEST")
        and valueCheck(expr))
    or not exists(FlaskLogin::getConfigValue("SESSION_REFRESH_EACH_REQUEST")))
  and exists(DataFlow::Node perma | 
    perma = API::moduleImport("flask").getMember("session").getMember("permanent").getAValueReachingSink()
    and perma.asExpr().(ImmutableLiteral).booleanValue() = true
    and exists(perma.getLocation().getFile().getRelativePath()))
select "Session is set to permanent and Session cookie lifetime is refreshed at each request"
