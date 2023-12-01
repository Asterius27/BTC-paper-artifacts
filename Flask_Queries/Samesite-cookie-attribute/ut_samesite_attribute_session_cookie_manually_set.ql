import python
import CodeQL_Library.FlaskLogin

// TODO might want to check if session cookies are disabled as part of the query
from Expr expr
where expr = FlaskLogin::getConfigValue("SESSION_COOKIE_SAMESITE")
select expr, expr.getLocation(), "Session cookie samesite attribute is manually set or disabled"
