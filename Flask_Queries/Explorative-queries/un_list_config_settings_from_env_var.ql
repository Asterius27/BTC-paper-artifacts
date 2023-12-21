import python
import CodeQL_Library.FlaskLogin

string auxsk(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SECRET_KEY", "secret_key"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SECRET_KEY", "secret_key")
        and result = "un_secret_key " + node.getLocation()
    else none()
}

string auxrcs(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SECURE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SECURE")
        and result = "ut_secure_attribute_remember_cookie " + node.getLocation()
    else none()
}

string auxscs(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SECURE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SECURE")
        and result = "ut_secure_attribute_session_cookie " + node.getLocation()
    else none()
}

string auxsch(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_HTTPONLY"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_HTTPONLY")
        and result = "un_httponly_attribute_session_cookie " + node.getLocation()
    else none()
}

string auxrch(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_HTTPONLY"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_HTTPONLY")
        and result = "un_httponly_attribute_rememeber_cookie " + node.getLocation()
    else none()
}

string auxscd(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_DOMAIN"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_DOMAIN")
        and result = "uf_domain_attribute_session_cookie " + node.getLocation()
    else none()
}

string auxrcd(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_DOMAIN"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_DOMAIN")
        and result = "uf_domain_attribute_remember_cookie " + node.getLocation()
    else none()
}

string auxscss(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SAMESITE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SAMESITE")
        and result = "st_samesite_attribute_session_cookie " + node.getLocation()
    else none()
}

string auxrcss(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SAMESITE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SAMESITE")
        and result = "st_samesite_attribute_remember_cookie " + node.getLocation()
    else none()
}

string auxscn(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_NAME"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_NAME")
        and result = "st_session_cookie_name_prefix " + node.getLocation()
    else none()
}

string auxrcn(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_NAME"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_NAME")
        and result = "st_remember_cookie_name_prefix " + node.getLocation()
    else none()
}

string auxrcrer(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_REFRESH_EACH_REQUEST"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_REFRESH_EACH_REQUEST")
        and result = "un_refresh_each_request_remember_cookie " + node.getLocation()
    else none()
}

string auxscrer(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_REFRESH_EACH_REQUEST"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_REFRESH_EACH_REQUEST")
        and result = "un_refresh_each_request_session_cookie " + node.getLocation()
    else none()
}

string aux(Expr node) {
    result = auxsk(node)
    or result = auxrcs(node)
    or result = auxscs(node)
    or result = auxsch(node)
    or result = auxrch(node)
    or result = auxscd(node)
    or result = auxrcd(node)
    or result = auxrcss(node)
    or result = auxscss(node)
    or result = auxscn(node)
    or result = auxrcn(node)
    or result = auxscrer(node)
    or result = auxrcrer(node)
}

from Expr node
select aux(node)
