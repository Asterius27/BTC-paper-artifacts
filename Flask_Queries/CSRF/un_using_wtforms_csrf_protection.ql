import python
import semmle.python.ApiGraphs

from Class cls, AssignStmt asgn, Class meta
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm")
    and meta = cls.getAStmt().(ClassDef).getDefinedClass()
    and meta.getName() = "Meta"
    and asgn = meta.getAStmt().(AssignStmt)
    and asgn.getATarget().toString() = "csrf"
    and asgn.getValue().(ImmutableLiteral).booleanValue() = true
select cls, cls.getLocation(), "This form has enabled wtforms csrf protection"
