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
    if exists(DjangoSession::overridenImplOfHashingAlgIsUsed("BCryptPasswordHasher"))
    then if not DjangoSession::getAttrValue(cls, "rounds") instanceof IntegerLiteral
        then result = "Bcrypt is being used as the password hashing algorithm but binary expressions are being used so don't know if it's owasp compliant"
        else result = "Bcrypt is being used as the password hashing algorithm and it's owasp compliant"
    else if exists(DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.BCryptPasswordHasher"))
        then result = "Bcrypt is being used as the password hashing algorithm and it's owasp compliant"
        else none()
}

from Class cls
where (cls = DjangoSession::overridenImplOfHashingAlgIsUsed("BCryptPasswordHasher")
        and not attrCheck(cls, "rounds", 10))
    or exists(DjangoSession::defaultImplOfHashingAlgIsUsed("django.contrib.auth.hashers.BCryptPasswordHasher"))
select output(cls)
