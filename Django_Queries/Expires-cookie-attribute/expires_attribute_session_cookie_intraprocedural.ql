import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// TODO there might be other ways to set the Expires (max-age) cookie attribute (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
bindingset[param]
int auxk(API::Node td, string param) {
    if exists(td.getKeywordParameter(param).getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
    then result = td.getKeywordParameter(param).getAValueReachingSink().asExpr().(IntegerLiteral).getValue()
    else result = 0
}

int keywords(API::Node td) {
    result = auxk(td, "weeks") * 604800
    + auxk(td, "days") * 86400
    + auxk(td, "seconds")
    + auxk(td, "microseconds") / 1000000
    + auxk(td, "milliseconds") / 1000
    + auxk(td, "minutes") * 60
    + auxk(td, "hours") * 3600
}

bindingset[pos]
int auxp(API::Node td, int pos) {
    if exists(td.getParameter(pos).getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
    then result = td.getParameter(pos).getAValueReachingSink().asExpr().(IntegerLiteral).getValue()
    else result = 0
}

int params(API::Node td) {
    result = auxp(td, 0) * 86400
    + auxp(td, 1)
    + auxp(td, 2) / 1000000
    + auxp(td, 3) / 1000
    + auxp(td, 4) * 60
    + auxp(td, 5) * 3600
    + auxp(td, 6) * 604800
}

predicate seconds() {
    exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
        exists(source.getLocation().getFile().getRelativePath())
        and exists(Attribute a, Call c | 
            exists(a.getLocation().getFile().getRelativePath())
            and a.getAttr() = "set_expiry"
            and a.getObject().(Attribute).getAttr() = "session"
            and c.getASubExpression() = a
            and (c.getPositionalArg(0) = sink.asExpr()
            or c.getNamedArg(0).(Keyword).getValue() = sink.asExpr())
        )
        and DataFlow::localFlow(source, sink)
        and source.asExpr().(IntegerLiteral).getValue() > 2592000
    )
}

predicate timedelta() {
    exists(DataFlow::ExprNode source, DataFlow::ExprNode sink, API::Node timedelta | 
        exists(source.getLocation().getFile().getRelativePath())
        and exists(Attribute a, Call c | 
            exists(a.getLocation().getFile().getRelativePath())
            and a.getAttr() = "set_expiry"
            and a.getObject().(Attribute).getAttr() = "session"
            and c.getASubExpression() = a
            and (c.getPositionalArg(0) = sink.asExpr()
            or c.getNamedArg(0).(Keyword).getValue() = sink.asExpr())
        )
        and DataFlow::localFlow(source, sink)
        and timedelta = API::moduleImport("datetime").getMember("timedelta")
        and source = timedelta.getReturn().getAValueReachableFromSource()
        and params(timedelta) + keywords(timedelta) > 2592000
    )
}

where exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
    source.asExpr().(IntegerLiteral).getValue() > 2592000
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SESSION_COOKIE_AGE"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
    and DataFlow::localFlow(source, sink))
    and not exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
        source.asExpr().(ImmutableLiteral).booleanValue() = true
        and exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_EXPIRE_AT_BROWSER_CLOSE"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue() = sink.asExpr()
        )
        and DataFlow::localFlow(source, sink))
        or (seconds() or timedelta())
select "Session cookie duration is too long"
