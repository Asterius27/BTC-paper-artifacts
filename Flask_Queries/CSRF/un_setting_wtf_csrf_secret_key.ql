import python
import CodeQL_Library.FlaskLogin

from Expr expr
where expr = FlaskLogin::getConfigValue("WTF_CSRF_SECRET_KEY")
select expr, expr.getLocation(), "Flask-WTF CSRF secret key is manually set"
