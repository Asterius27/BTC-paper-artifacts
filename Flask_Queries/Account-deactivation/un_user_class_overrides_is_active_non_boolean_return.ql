import python
import semmle.python.ApiGraphs

from Class cls, Function f
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "UserMixin"
    and cls.getAMethod() = f
    and f.getName() = "is_active"
    and exists(ControlFlowNode cfn |
        cfn = f.getAReturnValueFlowNode()
        and not cfn.isLiteral())
select cls, cls.getLocation(), "This user class overrides is_active with a property that has some custom logic and might return a boolean that is not a literal"
