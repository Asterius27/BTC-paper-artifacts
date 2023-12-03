import python
import CodeQL_Library.FlaskLogin

// TODO probably need to change the output to the name of the corresponding query
// for example un_secret_key instead of SECRET_KEY
string auxsk(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SECRET_KEY", "secret_key"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SECRET_KEY", "secret_key")
        and result = "SECRET_KEY " + node.getLocation()
    else none()
}

string auxrcs(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SECURE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SECURE")
        and result = "REMEMBER_COOKIE_SECURE " + node.getLocation()
    else none()
}

string auxscs(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SECURE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SECURE")
        and result = "SESSION_COOKIE_SECURE " + node.getLocation()
    else none()
}

string auxsch(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_HTTPONLY"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_HTTPONLY")
        and result = "SESSION_COOKIE_HTTPONLY " + node.getLocation()
    else none()
}

string auxrch(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_HTTPONLY"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_HTTPONLY")
        and result = "REMEMBER_COOKIE_HTTPONLY " + node.getLocation()
    else none()
}

string auxscd(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_DOMAIN"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_DOMAIN")
        and result = "SESSION_COOKIE_DOMAIN " + node.getLocation()
    else none()
}

string auxrcd(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_DOMAIN"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_DOMAIN")
        and result = "REMEMBER_COOKIE_DOMAIN " + node.getLocation()
    else none()
}

string auxscss(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SAMESITE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_SAMESITE")
        and result = "SESSION_COOKIE_SAMESITE " + node.getLocation()
    else none()
}

string auxrcss(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SAMESITE"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_SAMESITE")
        and result = "REMEMBER_COOKIE_SAMESITE " + node.getLocation()
    else none()
}

string auxscn(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_NAME"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("SESSION_COOKIE_NAME")
        and result = "SESSION_COOKIE_NAME " + node.getLocation()
    else none()
}

string auxrcn(Expr node) {
    if  exists(FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_NAME"))
    then node = FlaskLogin::getConfigSinkFromEnvVar("REMEMBER_COOKIE_NAME")
        and result = "REMEMBER_COOKIE_NAME " + node.getLocation()
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
}

from Expr node
select aux(node)
