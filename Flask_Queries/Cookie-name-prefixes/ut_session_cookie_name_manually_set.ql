import python
import CodeQL_Library.FlaskLogin

// TODO might want to check if session cookies are disabled as part of the query
from Expr expr
where expr = FlaskLogin::getConfigValue("SESSION_COOKIE_NAME")
select expr, expr.getLocation(), "Session cookie name is manually set"
