import python
import semmle.python.ApiGraphs

from Class cls, Function f
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
    and cls.getAMethod() = f
    and f.getName() = "is_active"
    and forall(ControlFlowNode cfn |
        cfn = f.getAReturnValueFlowNode() |
        cfn.inferredValue().getABooleanValue() = true)
select cls, cls.getLocation(), "This user class overrides is_active with a property that always returns true"
