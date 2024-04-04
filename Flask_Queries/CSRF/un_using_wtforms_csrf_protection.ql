import python
import semmle.python.ApiGraphs

predicate csrfEnabledInMetaSubclass(Class cls) {
    exists(AssignStmt asgn, Class meta | 
        meta = cls.getAStmt().(ClassDef).getDefinedClass()
        and meta.getName() = "Meta"
        and asgn = meta.getAStmt().(AssignStmt)
        and asgn.getATarget().toString() = "csrf"
        and asgn.getValue().(ImmutableLiteral).booleanValue() = true)
}

predicate csrfEnabledOnTheFly(Class cls) {
    exists(Keyword item, Call call, KeyValuePair meta |
        call.getAFlowNode() = cls.getClassObject().getACall()
        and ((call.getNamedArgs().getAnItem().(Keyword) = item
                and item.getArg() = "meta"
                and item.getValue().(Dict).getAnItem().(KeyValuePair) = meta)
            or call.getPositionalArg(4).(Dict).getAnItem().(KeyValuePair) = meta)
        and meta.getKey().(StrConst).getS() = "csrf"
        and meta.getValue().(ImmutableLiteral).booleanValue() = true)
}

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and (cls.getABase().toString() = "Form"
        or cls.getABase().toString() = "BaseForm")
    and (csrfEnabledInMetaSubclass(cls)
        or csrfEnabledOnTheFly(cls))
select cls, cls.getLocation(), "This form has enabled wtforms csrf protection at least once"
