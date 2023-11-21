import python
import CodeQL_Library.FlaskLogin

// TODO might want to check if session cookies are disabled as part of the query
predicate valueCheck(Expr expr) {
  expr.(ImmutableLiteral).booleanValue() = false
}

from Expr expr
where expr = FlaskLogin::getConfigValue("SESSION_COOKIE_SECURE")
  and valueCheck(expr)
select expr, expr.getLocation(), "Session cookie secure attribute set to false"
