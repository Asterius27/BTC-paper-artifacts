import python
import CodeQL_Library.FlaskLogin

DataFlow::Node getSessionProtectionSource() {
    exists(DataFlow::Node n |
        (n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
            or n = API::moduleImport("flask_login").getMember("login_manager").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())
        and result = n)
}

string auxsk(Expr expr) {
    if count(Expr exp | exp = FlaskLogin::getConfigValue("SECRET_KEY", "secret_key") | exp) > 1
    then expr = FlaskLogin::getConfigValue("SECRET_KEY", "secret_key")
        and exists(expr.getLocation().getFile().getRelativePath())
        and result = "un_secret_key " + expr.getLocation()
    else none()
}

string auxsp(Expr expr) {
    if count(Expr exp | exp = getSessionProtectionSource().asExpr() | exp) > 1
    then expr = getSessionProtectionSource().asExpr()
        and exists(expr.getLocation().getFile().getRelativePath())
        and result = "sf_session_protection sf_session_protection_strong uf_session_protection_basic " + expr.getLocation()
    else none()
}

string auxsi(Expr expr) {
    if count(Expr exp | exp = FlaskLogin::getConfigValueFromAttribute("session_interface") | exp) > 1
    then expr = FlaskLogin::getConfigValueFromAttribute("session_interface")
        and exists(expr.getLocation().getFile().getRelativePath())
        and result = "un_custom_session_interface " + expr.getLocation()
    else none()
}

string aux(Expr node) {
    result = auxsk(node)
    or result = auxsp(node)
    or result = auxsi(node)
}

from Expr node
select aux(node)
