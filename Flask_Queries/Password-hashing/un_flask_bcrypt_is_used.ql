import python
import semmle.python.ApiGraphs

from API::Node node
where node = API::moduleImport("flask_bcrypt").getMember("Bcrypt").getReturn()
select node.asSource().getLocation(), "Flask-Bcrypt is being used"
