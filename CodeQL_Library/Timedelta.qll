import python
import semmle.python.ApiGraphs

module Timedelta {
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

    int getSecondsFromTimedeltaCall(API::Node timedelta) {
        result = params(timedelta) + keywords(timedelta)
    }
}