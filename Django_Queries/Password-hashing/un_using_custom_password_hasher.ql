import python
import CodeQL_Library.DjangoSession

// TODO doesn't work (maybe forall could fix this?)
from Class cls, StrConst str
where str = DjangoSession::getDefaultHashingAlg()
    and cls.getName() = str.getS().splitAt(".")
//    and not cls.getABase() = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("hashers").getAMember().getAValueReachableFromSource().asExpr()
    and str.getS().prefix(28) != "django.contrib.auth.hashers."
select cls, cls.getLocation(), "Using a completely custom password hasher"
