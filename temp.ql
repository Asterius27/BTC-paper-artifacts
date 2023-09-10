import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask
import semmle.python.dataflow.new.DataFlow2

// This works (other ways of setting/updating multiple keys)
from DataFlow::Node node
where (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("REMEMBER_COOKIE_SAMESITE").getAValueReachingSink()
    and node.asExpr().toString() = "None")
    or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
    and node.asExpr().(Dict).getAnItem().(KeyValuePair).getKey().(Str).getText() = "REMEMBER_COOKIE_SAMESITE"
    and node.asExpr().(Dict).getAnItem().(KeyValuePair).getValue().toString() = "None")
select node.getLocation()
