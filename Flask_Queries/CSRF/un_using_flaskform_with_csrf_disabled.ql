import python
import semmle.python.ApiGraphs

from Class cls, AssignStmt asgn, Class meta, Keyword item, Call call
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "FlaskForm"
    and ((meta = cls.getAStmt().(ClassDef).getDefinedClass()
            and meta.getName() = "Meta"
            and asgn = meta.getAStmt().(AssignStmt)
            and asgn.getATarget().toString() = "csrf"
            and asgn.getValue().(ImmutableLiteral).booleanValue() = false)
        or (
            call.getAFlowNode() = cls.getClassObject().getACall()
            and call.getNamedArgs().getAnItem().(Keyword) = item
            and item.getArg() = "meta"
        ))
select cls, cls.getLocation(), item.getValue(), "This form has enabled wtforms csrf protection"
