import python
import semmle.python.ApiGraphs

predicate csrfDisabledInMetaSubclass(Class cls) {
    exists(AssignStmt asgn, Class meta | 
        meta = cls.getAStmt().(ClassDef).getDefinedClass()
        and meta.getName() = "Meta"
        and asgn = meta.getAStmt().(AssignStmt)
        and asgn.getATarget().toString() = "csrf"
        and asgn.getValue().(ImmutableLiteral).booleanValue() = false)
}

predicate csrfDisabledOnTheFly(Class cls) {
    exists(Keyword item, Call call, KeyValuePair meta |
        call.getAFlowNode() = cls.getClassObject().getACall()
        and call.getNamedArgs().getAnItem().(Keyword) = item
        and item.getArg() = "meta"
        and item.getValue().(Dict).getAnItem().(KeyValuePair) = meta
        and meta.getKey().(StrConst).getS() = "csrf"
        and meta.getValue().(ImmutableLiteral).booleanValue() = false)
}

from Class cls
where exists(cls.getLocation().getFile().getRelativePath())
    and cls.getABase().toString() = "FlaskForm"
    and (csrfDisabledInMetaSubclass(cls)
        or csrfDisabledOnTheFly(cls))
select cls, cls.getLocation(), "This form (FlaskForm) has disabled csrf protection at least once"
