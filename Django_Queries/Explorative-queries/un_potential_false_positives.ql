import python
import CodeQL_Library.DjangoSession

bindingset[configsetting]
AssignStmt aux(string configsetting) {
    exists(Name name, AssignStmt asgn |
        name.getId() = configsetting
        and asgn.getATarget() = name
        and result = asgn)
}

bindingset[configsetting, queryname]
string auxx(string configsetting, string queryname) {
    if count(AssignStmt asgn | asgn = aux(configsetting)) > 1
    then result = queryname + " " + aux(configsetting).getLocation()
    else none()
}

string output() {
    result = auxx("SECRET_KEY", "un_secret_key")
    or result = auxx("SESSION_SERIALIZER", "un_session_serializer")
    or result = auxx("AUTH_PASSWORD_VALIDATORS", "un_using_password_validators")
    or result = auxx("PASSWORD_HASHERS", "un_manually_set_password_hashers")
    or result = auxx("AUTHENTICATION_BACKENDS", "un_custom_auth_backends")
    or result = auxx("SESSION_ENGINE", "custom_session_engine")
}

select output()
