import python
import CodeQL_Library.FlaskLogin

// Used just to check if config.from_file, config.fromkeys and config.from_mapping are used a lot or not
// TODO In case they are very used I need to add them also to the other queries
from DataFlow::Node node
where (node = FlaskLogin::getConfigSourceFromFile()
    or node = FlaskLogin::getConfigSourceFromKeys()
    or node = FlaskLogin::getConfigSourceFromMapping())
    and exists(node.getLocation().getFile().getRelativePath())
select node, node.getLocation(), node.asExpr().(Attribute).getName()
