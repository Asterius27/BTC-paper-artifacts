import python
import CodeQL_Library.FlaskLogin

from Expr expr
where expr = FlaskLogin::getConfigValueFromAttribute("session_interface")
select expr, expr.getAFlowNode(), expr.getLocation(), "Using a custom session interface"
