import python
import semmle.python.ApiGraphs

from Class cls, AssignStmt asgn, Class meta, DictItem item, Call call
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "FlaskForm"
    and ((meta = cls.getAStmt().(ClassDef).getDefinedClass()
            and meta.getName() = "Meta"
            and asgn = meta.getAStmt().(AssignStmt)
            and asgn.getATarget().toString() = "csrf"
            and asgn.getValue().(ImmutableLiteral).booleanValue() = false)
        or (
            call.getAFlowNode() = cls.getClassObject().getACall()
            and call.getNamedArgs().getAnItem() = item
            and item
        ))
select cls, cls.getLocation(), "This form has enabled wtforms csrf protection"
