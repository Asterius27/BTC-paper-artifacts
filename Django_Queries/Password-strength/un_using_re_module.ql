import python
import semmle.python.ApiGraphs

from DataFlow::Node password, DataFlow::Node pattern, API::CallNode call
where call = API::moduleImport("re").getAMember().getACall()
    and password = call.getParameter(1, "string").getAValueReachingSink()
    and exists(password.getLocation().getFile().getRelativePath())
    and pattern = call.getParameter(0, "pattern").getAValueReachingSink()
    and exists(pattern.getLocation().getFile().getRelativePath())
select pattern.asExpr().(StrConst).getS(), pattern.getLocation(), password, password.getLocation()
