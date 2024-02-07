import python
import CodeQL_Library.DjangoSession

bindingset[attrName, value]
predicate attrCheck(Class cls, string attrName, int value) {
    exists(Expr expr |
        expr = DjangoSession::getAttrValue(cls, attrName)
        and if expr instanceof IntegerLiteral
            then expr.(IntegerLiteral).getValue() < value
            else none())
}

bindingset[attrName, value]
predicate attrCheckNonCompliant(Class cls, string attrName, int value) {
    exists(Expr expr |
        expr = DjangoSession::getAttrValue(cls, attrName)
        and if expr instanceof IntegerLiteral
            then expr.(IntegerLiteral).getValue() < value
            else none())
    or not exists(DjangoSession::getAttrValue(cls, attrName))
}

string output(Class cls) {
    if exists(DjangoSession::overridenImplOfHashingAlgIsUsed("PBKDF2PasswordHasher")) or exists(DjangoSession::overridenImplOfHashingAlgIsUsed("PBKDF2SHA1PasswordHasher"))
    then if not DjangoSession::getAttrValue(cls, "iterations") instanceof IntegerLiteral
        then result = "PBKDF2 is being used as the password hashing algorithm but binary expressions are being used so don't know if it's owasp compliant"
        else result = "PBKDF2 is being used as the password hashing algorithm and it's owasp compliant"
    else if exists(DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.PBKDF2PasswordHasher")) or not exists(DataFlow3::Node source, DataFlow3::Node sink, DjangoSession::PasswordHashersConfiguration config | config.hasFlow(source, sink))
        then result = "PBKDF2 is being used as the password hashing algorithm and it's owasp compliant"
        else none()
}

from Class cls
where (cls = DjangoSession::overridenImplOfHashingAlgIsUsed("PBKDF2PasswordHasher")
        and not attrCheck(cls, "iterations", 600000))
    or (cls = DjangoSession::overridenImplOfHashingAlgIsUsed("PBKDF2SHA1PasswordHasher")
        and not attrCheckNonCompliant(cls, "iterations", 1300000))
    or exists(DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.PBKDF2PasswordHasher"))
    or not exists(DataFlow3::Node source, DataFlow3::Node sink, DjangoSession::PasswordHashersConfiguration config |
        config.hasFlow(source, sink))
select output(cls)
