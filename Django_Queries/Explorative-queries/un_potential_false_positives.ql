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
    exists(AssignStmt asgn1, AssignStmt asgn2 |
        asgn1 = aux(configsetting)
        and asgn2 = aux(configsetting)
        and asgn1 != asgn2
        and exists(asgn1.getLocation().getFile().getRelativePath())
        and exists(asgn2.getLocation().getFile().getRelativePath())
        and asgn1.getLocation().toString() != asgn2.getLocation().toString()
        and result = queryname + " " + asgn1 + " " + asgn1.getLocation() + " " + asgn2 + " " + asgn2.getLocation())
}

bindingset[configsetting, queryname]
string auxsk(string configsetting, string queryname) {
    exists(AssignStmt asgn1, AssignStmt asgn2 |
        asgn1 = aux(configsetting)
        and asgn2 = aux(configsetting)
        and asgn1 != asgn2
        and exists(asgn1.getLocation().getFile().getRelativePath())
        and exists(asgn2.getLocation().getFile().getRelativePath())
        and asgn1.getLocation().toString() != asgn2.getLocation().toString()
        and (not asgn1.getValue() instanceof Str
            or not asgn2.getValue() instanceof Str)
        and result = queryname + " " + asgn1 + " " + asgn1.getLocation() + " " + asgn2 + " " + asgn2.getLocation())
}

string output() {
    result = auxsk("SECRET_KEY", "un_secret_key")
    or result = auxx("SESSION_SERIALIZER", "un_session_serializer")
    or result = auxx("AUTH_PASSWORD_VALIDATORS", "un_using_password_validators")
    or result = auxx("PASSWORD_HASHERS", "un_manually_set_password_hashers")
    or result = auxx("AUTHENTICATION_BACKENDS", "un_custom_auth_backends")
    or result = auxx("SESSION_ENGINE", "custom_session_engine")
    or result = auxx("MIDDLEWARE", "un_csrf_protection_is_disabled")
    or result = auxx("MIDDLEWARE_CLASSES", "un_csrf_protection_is_disabled")
}

select output()
