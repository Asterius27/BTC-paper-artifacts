import python
import CodeQL_Library.FlaskLogin

predicate valueCheck(Expr expr) {
    expr.(ImmutableLiteral).booleanValue() = false
}

from Expr expr
where expr = FlaskLogin::getConfigValue("WTF_CSRF_ENABLED")
  and valueCheck(expr)
select expr, expr.getLocation(), "Flask-WTF CSRF protection is manually disabled"
