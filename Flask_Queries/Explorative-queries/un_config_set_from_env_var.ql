import python
import CodeQL_Library.FlaskLogin

// Just to know, out of curiosity, how many set the whole config using environment variables
from DataFlow::Node node
where node = FlaskLogin::getConfigSourceFromEnvFile()
    and exists(node.getLocation().getFile().getRelativePath())
select node, node.getLocation()
