import python
import semmle.python.ApiGraphs

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
    and not exists(Function f | 
        cls.getAMethod() = f
        and f.getName() = "is_active"
        and f.getAReturnValueFlowNode().inferredValue().getABooleanValue() != true)
select cls, cls.getLocation(), "Deactivated users are allowed to log in and user class extends Flask's UserMixin class, but deactivation handling is left as default (all accounts are always active)"
