import python
import CodeQL_Library.FlaskLogin

// TODO might want to check if session cookies are disabled as part of the query
predicate valueCheck(Expr expr) {
  expr.toString() = "None"
}

from Expr expr
where expr = FlaskLogin::getConfigValue("REMEMBER_COOKIE_DOMAIN")
  and valueCheck(expr)
select expr, expr.getLocation(), "Remember cookie domain attribute is manually disabled"
