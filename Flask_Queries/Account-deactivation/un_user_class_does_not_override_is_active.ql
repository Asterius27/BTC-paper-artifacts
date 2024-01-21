import python
import semmle.python.ApiGraphs

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
    and forall(Function g | 
        cls.getAMethod() = g |
        g.getName() != "is_active")
select cls, cls.getLocation(), "This user class doesn't override is_active (default behaviour is to always return true)"
