import python
import CodeQL_Library.FlaskLogin

string output(Expr seckey) {
  if seckey.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

from Expr expr, StrConst str
where (expr = FlaskLogin::getConfigValue("SECRET_KEY", "secret_key")
    	and expr instanceof StrConst
		and str = expr)
	or (expr = FlaskLogin::getConfigSinkFromEnvVar("SECRET_KEY", "secret_key")
		and exists(expr.getLocation().getFile().getRelativePath())
		and (str = expr.(Call).getNamedArg(0).(Keyword).getValue().(StrConst)
			or str = expr.(Call).getPositionalArg(1).(StrConst)))
select str, str.getLocation(), output(str), str.getS()
