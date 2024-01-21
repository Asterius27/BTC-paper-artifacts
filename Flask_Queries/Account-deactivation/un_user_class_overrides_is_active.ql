import python
import semmle.python.ApiGraphs

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
    and exists(Function g | 
        cls.getAMethod() = g
        and g.getName() = "is_active")
select cls, cls.getLocation(), "This user class overrides is_active property"
