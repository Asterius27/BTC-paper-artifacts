import python
import CodeQL_Library.FlaskLogin

DataFlow::Node getSessionProtectionSource() {
    exists(DataFlow::Node n |
        (n = API::moduleImport("flask_login").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink()
            or n = API::moduleImport("flask_login").getMember("login_manager").getMember("LoginManager").getReturn().getMember("session_protection").getAValueReachingSink())
        and result = n)
}

string auxsk() {
    exists(Expr expr1, Expr expr2 |
        expr1 = FlaskLogin::getConfigValue("SECRET_KEY", "secret_key")
        and expr2 = FlaskLogin::getConfigValue("SECRET_KEY", "secret_key")
        and expr1 != expr2
        and exists(expr1.getLocation().getFile().getRelativePath())
        and exists(expr2.getLocation().getFile().getRelativePath())
        and expr1.getLocation().toString() != expr2.getLocation().toString()
        and result = "un_secret_key " + expr1 + " " + expr1.getLocation() + " " + expr2 + " " + expr2.getLocation())
}

string auxsp() {
    exists(Expr expr1, Expr expr2 |
        expr1 = getSessionProtectionSource().asExpr()
        and expr2 = getSessionProtectionSource().asExpr()
        and expr1 != expr2
        and exists(expr1.getLocation().getFile().getRelativePath())
        and exists(expr2.getLocation().getFile().getRelativePath())
        and expr1.getLocation().toString() != expr2.getLocation().toString()
        and result = "sf_session_protection sf_session_protection_strong uf_session_protection_basic un_session_protection_basic_is_used " + expr1 + " " + expr1.getLocation() + " " + expr2 + " " + expr2.getLocation())
}

string auxsi() {
    exists(Expr expr1, Expr expr2 |
        expr1 = FlaskLogin::getConfigValueFromAttribute("session_interface")
        and expr2 = FlaskLogin::getConfigValueFromAttribute("session_interface")
        and expr1 != expr2
        and exists(expr1.getLocation().getFile().getRelativePath())
        and exists(expr2.getLocation().getFile().getRelativePath())
        and expr1.getLocation().toString() != expr2.getLocation().toString()
        and result = "un_custom_session_interface " + expr1 + " " + expr1.getLocation() + " " + expr2 + " " + expr2.getLocation())
}

string auxphfb() {
    exists(Expr expr1, Expr expr2 |
        expr1 = FlaskLogin::getConfigValue("BCRYPT_LOG_ROUNDS")
        and expr2 = FlaskLogin::getConfigValue("BCRYPT_LOG_ROUNDS")
        and expr1 != expr2
        and exists(expr1.getLocation().getFile().getRelativePath())
        and exists(expr2.getLocation().getFile().getRelativePath())
        and expr1.getLocation().toString() != expr2.getLocation().toString()
        and result = "un_flask_bcrypt_is_owasp_compliant " + expr1 + " " + expr1.getLocation() + " " + expr2 + " " + expr2.getLocation())
}

string aux() {
    result = auxsk()
    or result = auxsp()
    or result = auxsi()
    or result = auxphfb()
}

select aux()
