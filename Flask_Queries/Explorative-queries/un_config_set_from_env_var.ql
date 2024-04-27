import python
import CodeQL_Library.FlaskLogin

from DataFlow::Node node
where node = FlaskLogin::getConfigSourceFromEnvFile()
    and exists(node.getLocation().getFile().getRelativePath())
select node, node.getLocation()
