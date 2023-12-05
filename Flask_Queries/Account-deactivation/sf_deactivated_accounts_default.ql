import python
import semmle.python.ApiGraphs

from Class cls
where cls.getClassObject().getASuperType().getPyClass().getName() = "UserMixin"
    and (exists(Function f | 
        cls.getAMethod() = f
        and f.getName() = "is_active"
        and f.getReturnNode().isLiteral())
    or not exists(Function f | 
        cls.getAMethod() = f
        and f.getName() = "is_active"))
select cls, cls.getLocation(), "Deactivated users are allowed to log in and user class extends Flask's UserMixin class, but deactivation handling is left as default"
