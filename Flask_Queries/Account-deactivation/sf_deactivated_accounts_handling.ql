import python
import semmle.python.ApiGraphs

from Class cls, Function f
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
    and cls.getAMethod() = f
    and f.getName() = "is_active"
    and f.getAReturnValueFlowNode().inferredValue().getABooleanValue() != true
select cls, cls.getLocation(), "Deactivated users are allowed to log in and deactivation is handled by overriding the is_active UserMixin property"
