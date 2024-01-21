import python
import semmle.python.ApiGraphs

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
select cls, cls.getLocation(), "Found a class that extends UserMixin, so it could be the application's the user class"
