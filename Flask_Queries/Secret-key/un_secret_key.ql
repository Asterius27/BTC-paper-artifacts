import python
import CodeQL_Library.FlaskLogin

string output(Expr seckey) {
  if seckey.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

from Expr expr
where expr = FlaskLogin::getConfigValue("SECRET_KEY", "secret_key")
  and expr instanceof StrConst
select expr, expr.getLocation(), output(expr), expr.(StrConst).getS()
