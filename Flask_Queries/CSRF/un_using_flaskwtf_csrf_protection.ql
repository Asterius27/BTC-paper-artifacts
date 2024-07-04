import python
import semmle.python.ApiGraphs

from API::Node node, DataFlow::Node n
where (node = API::moduleImport("flask_wtf").getMember("csrf").getMember("CSRFProtect")
        or node = API::moduleImport("flask_wtf").getMember("CSRFProtect")
        or node = API::moduleImport("flask_wtf").getMember("csrf").getMember("CSRFProtect").getReturn().getMember("init_app")
        or node = API::moduleImport("flask_wtf").getMember("CSRFProtect").getReturn().getMember("init_app"))
    and (exists(node.getParameter(0).getAValueReachingSink())
        or exists(node.getKeywordParameter("app").getAValueReachingSink()))
    and (n = node.getAValueReachableFromSource()
        or n = node.getAValueReachingSink())
    and exists(n.asCfgNode())
    and not n.asExpr() instanceof ImportMember
select n, n.getLocation(), "Flask-WTF csrf protection is enabled globally"
