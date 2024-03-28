import python
import semmle.python.ApiGraphs

from API::Node node, DataFlow::Node n
where (node = API::moduleImport("flask_wtf").getMember("csrf").getMember("CSRFProtect")
        or node = API::moduleImport("flask_wtf").getMember("csrf").getMember("CSRFProtect"))
    and (exists(node.getParameter(0).getAValueReachingSink())
        or exists(node.getKeywordParameter("app").getAValueReachingSink())
        or exists(node.getReturn().getMember("init_app").getParameter(0).getAValueReachingSink())
        or exists(node.getReturn().getMember("init_app").getKeywordParameter("app").getAValueReachingSink()))
    and n = node.getReturn().getMember("protect").getAValueReachableFromSource()
    and exists(n.asCfgNode())
    and not n.asExpr() instanceof ImportMember
select n, n.getLocation(), "Flask-WTF csrf protection is enabled selectively using csrf protect"
