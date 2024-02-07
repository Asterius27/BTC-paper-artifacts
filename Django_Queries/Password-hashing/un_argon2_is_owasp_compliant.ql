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

string output(Class cls) {
    if exists(DjangoSession::overridenImplOfHashingAlgIsUsed("Argon2PasswordHasher"))
    then if not DjangoSession::getAttrValue(cls, "time_cost") instanceof IntegerLiteral or not DjangoSession::getAttrValue(cls, "memory_cost") instanceof IntegerLiteral or not DjangoSession::getAttrValue(cls, "parallelism") instanceof IntegerLiteral
        then result = "Argon2 is being used as the password hashing algorithm but binary expressions are being used so don't know if it's owasp compliant"
        else result = "Argon2 is being used as the password hashing algorithm and it's owasp compliant"
    else if exists(DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.Argon2PasswordHasher"))
        then result = "Argon2 is being used as the password hashing algorithm and it's owasp compliant"
        else none()
}

from Class cls
where (cls = DjangoSession::overridenImplOfHashingAlgIsUsed("Argon2PasswordHasher")
        and not attrCheck(cls, "time_cost", 2)
        and not attrCheck(cls, "memory_cost", 19456)
        and not attrCheck(cls, "parallelism", 1))
    or exists(DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.Argon2PasswordHasher"))
select output(cls)
