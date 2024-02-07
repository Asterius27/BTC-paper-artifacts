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
    if not DjangoSession::getAttrValue(cls, "work_factor") instanceof IntegerLiteral or not DjangoSession::getAttrValue(cls, "block_size") instanceof IntegerLiteral or not DjangoSession::getAttrValue(cls, "parallelism") instanceof IntegerLiteral
    then result = "Scrypt is being used as the password hashing algorithm but binary expressions are being used so don't know if it's owasp compliant"
    else result = "Scrypt is being used as the password hashing algorithm and it's owasp compliant"
}

from Class cls
where (cls = DjangoSession::overridenImplOfHashingAlgIsUsed("ScryptPasswordHasher")
        and not attrCheckNonCompliant(cls, "work_factor", 131072)
        and not attrCheck(cls, "block_size", 8)
        and not attrCheck(cls, "parallelism", 1))
select output(cls)
