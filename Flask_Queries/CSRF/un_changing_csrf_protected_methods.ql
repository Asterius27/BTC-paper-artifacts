import python
import CodeQL_Library.FlaskLogin

from Expr expr
where expr = FlaskLogin::getConfigValue("WTF_CSRF_METHODS")
select expr, expr.getLocation(), "Flask-WTF CSRF protected methods are manually set"
