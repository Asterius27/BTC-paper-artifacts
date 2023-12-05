import python
import semmle.python.ApiGraphs

from Class cls, Function f
where cls.getClassObject().getASuperType().getPyClass().getName() = "UserMixin"
    and cls.getAMethod() = f
    and f.getName() = "is_active"
    and not f.getReturnNode().isLiteral()
select cls, cls.getLocation(), "Deactivated users are allowed to log in and deactivation is handled by overriding the is_active UserMixin property"
