import python
import CodeQL_Library.DjangoSession

from Class cls, StrConst str
where str = DjangoSession::getDefaultHashingAlg()
    and cls.getName() = str.getS().splitAt(".")
    and not cls.getABase() = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("hashers").getAMember().getAValueReachableFromSource().asExpr()
    and (if exists(str.getS().prefix(28))
        then str.getS().prefix(28) != "django.contrib.auth.hashers."
        else any())
    and exists(cls.getLocation().getFile().getRelativePath())
select cls, cls.getLocation(), "Using a completely custom password hasher"
