import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where node = API::moduleImport("flask_wtf").getMember("FlaskForm").getAValueReachableFromSource()
    and not node.asExpr() instanceof ImportMember
    and exists(node.asCfgNode())
select node, node.getLocation(), "Flask-WTF is being used"
