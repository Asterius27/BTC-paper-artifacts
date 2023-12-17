import python
import CodeQL_Library.FlaskLogin

predicate valueCheck(Expr expr) {
    expr.(ImmutableLiteral).booleanValue() = true
}

from Expr expr
where expr = FlaskLogin::getConfigValue("REMEMBER_COOKIE_REFRESH_EACH_REQUEST")
  and valueCheck(expr)
select expr, expr.getLocation(), "Remember cookie lifetime is refreshed at each request"
