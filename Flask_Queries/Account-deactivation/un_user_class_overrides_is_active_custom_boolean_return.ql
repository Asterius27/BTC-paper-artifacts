import python
import semmle.python.ApiGraphs

from Class cls, Function f
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
    and cls.getAMethod() = f
    and f.getName() = "is_active"
    and forall(ControlFlowNode cfn |
        cfn = f.getAReturnValueFlowNode() |
        cfn.isLiteral())
    and exists(ControlFlowNode cfn |
        cfn = f.getAReturnValueFlowNode()
        and cfn.inferredValue().getABooleanValue() = true)
    and exists(ControlFlowNode cfn |
        cfn = f.getAReturnValueFlowNode()
        and cfn.inferredValue().getABooleanValue() = false)
select cls, cls.getLocation(), "This user class overrides is_active with a property that has some custom logic but always returns a literal (either true or false)"
