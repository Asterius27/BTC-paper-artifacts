import python
import semmle.python.ApiGraphs

from DataFlow::Node password, DataFlow::Node pattern, API::CallNode call
where call = API::moduleImport("re").getAMember().getACall()
    and password = call.getParameter(1, "string").asSink()
    and exists(password.getLocation().getFile().getRelativePath())
    and pattern = call.getParameter(0, "pattern").asSink()
    and exists(pattern.getLocation().getFile().getRelativePath())
    and (password.asExpr().(Name).getId() = "password"
        or password.asExpr().(Attribute).getAttr() = "password"
        or password.asExpr().(Name).getId() = "passwd"
        or password.asExpr().(Attribute).getAttr() = "passwd"
        or password.asExpr().(Name).getId() = "pwd"
        or password.asExpr().(Attribute).getAttr() = "pwd")
select pattern.asExpr().(StrConst).getS(), pattern.getLocation(), password, password.getLocation()
