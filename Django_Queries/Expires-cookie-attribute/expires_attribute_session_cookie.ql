import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.DataFlow2
import semmle.python.dataflow.new.DataFlow3
import semmle.python.ApiGraphs

// TODO intraprocedural version of the query
// TODO there might be other ways to set the Expires (max-age) cookie attribute (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
class AgeConfiguration extends DataFlow::Configuration {
    AgeConfiguration() { this = "AgeConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr().(IntegerLiteral).getValue() > 2592000 // 30 days
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_COOKIE_AGE"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

class BrowserConfiguration extends DataFlow2::Configuration {
    BrowserConfiguration() { this = "BrowserConfiguration" }

    override predicate isSource(DataFlow2::Node source) {
        source.asExpr().(ImmutableLiteral).booleanValue() = true
    }

    override predicate isSink(DataFlow2::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SESSION_EXPIRE_AT_BROWSER_CLOSE"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

class SetExpiryConfiguration extends DataFlow3::Configuration {
    SetExpiryConfiguration() { this = "SetExpiryConfiguration" }

    override predicate isSource(DataFlow3::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
    }

    override predicate isSink(DataFlow3::Node sink) {
        exists(Attribute a, Call c | 
            exists(a.getLocation().getFile().getRelativePath())
            and a.getAttr() = "set_expiry"
            and a.getObject().(Attribute).getAttr() = "session"
            and c.getASubExpression() = a
            and (c.getPositionalArg(0) = sink.asExpr()
            or c.getNamedArg(0).(Keyword).getValue() = sink.asExpr())
        )
    }
}

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
    exists(DataFlow3::Node source, DataFlow3::Node sink, SetExpiryConfiguration config | 
        config.hasFlow(source, sink)
        // and source.asExpr().toString() != "None"
        and source.asExpr().(IntegerLiteral).getValue() > 2592000
    )
}

predicate timedelta() {
    exists(DataFlow3::Node source, DataFlow3::Node sink, SetExpiryConfiguration config, API::Node timedelta | 
        config.hasFlow(source, sink)
        and timedelta = API::moduleImport("datetime").getMember("timedelta")
        and source = timedelta.getReturn().getAValueReachableFromSource()
        and params(timedelta) + keywords(timedelta) > 2592000
    )
}

where (exists(DataFlow::Node source, DataFlow::Node sink, AgeConfiguration config | 
        config.hasFlow(source, sink))
    and not exists(DataFlow2::Node source, DataFlow2::Node sink, BrowserConfiguration config | 
        config.hasFlow(source, sink)))
    or (seconds() or timedelta())
select "Session cookie duration is too long"

/* This works
where exists(DataFlow::Node source, DataFlow::Node sink, AgeConfiguration config | 
        config.hasFlow(source, sink))
    and exists(DataFlow2::Node source, DataFlow2::Node sink, BrowserConfiguration config | 
        config.hasFlow(source, sink))
select "Session cookie duration is too long"
*/

/* This works
where seconds() or timedelta()
select "Session cookie duration is too long"
*/

/* This has performance problems, takes too long and couldn't test it (it's slow probably because of the "or")
from DataFlow3::Node source, DataFlow3::Node sink, SetExpiryConfiguration config, API::Node timedelta
where config.hasFlow(source, sink)
    and source.asExpr().toString() != "None"
    and (
        (exists(source.asExpr().(IntegerLiteral).getValue())
        and source.asExpr().(IntegerLiteral).getValue() < 2592000)
        or (timedelta = API::moduleImport("datetime").getMember("timedelta")
            and not exists(source.asExpr().(IntegerLiteral).getValue())
            and exists(timedelta.getReturn().getAValueReachableFromSource().getLocation().getFile().getRelativePath())
            and source = timedelta.getReturn().getAValueReachableFromSource()
            and params(timedelta) + keywords(timedelta) < 2592000
        )
    )
select source, sink, source.getLocation(), sink.getLocation()
*/

/* This works
from DataFlow3::Node source, DataFlow3::Node sink, SetExpiryConfiguration config
where config.hasFlow(source, sink)
    and source.asExpr().toString() != "None"
    and source.asExpr().(IntegerLiteral).getValue() < 2592000
select source, sink, source.getLocation(), sink.getLocation()
*/

/* This works
from DataFlow3::Node source, DataFlow3::Node sink, SetExpiryConfiguration config, API::Node timedelta
where config.hasFlow(source, sink)
    and timedelta = API::moduleImport("datetime").getMember("timedelta")
    and source = timedelta.getReturn().getAValueReachableFromSource()
    and params(timedelta) + keywords(timedelta) < 2592000
select source, sink, timedelta, source.getLocation(), sink.getLocation()
*/

/* This works
from API::Node node
where node = API::moduleImport("datetime").getMember("timedelta")
    and exists(node.getReturn().getAValueReachableFromSource().getLocation().getFile().getRelativePath())
select node.getReturn().getAValueReachableFromSource(), node.getReturn().getAValueReachableFromSource().getLocation()
*/

/* This works
from Attribute a, Call c
where exists(a.getLocation().getFile().getRelativePath())
    and a.getAttr() = "set_expiry"
    and a.getObject().(Attribute).getAttr() = "session"
    and c.getASubExpression() = a
select c, c.getLocation(), c.getNamedArg(0).(Keyword).getValue(), c.getPositionalArg(0)
*/
