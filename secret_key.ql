import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask
// import semmle.python.dataflow.new.DataFlow2

/*
class SecKeyConfig extends DataFlow2::Configuration {
  SecKeyConfig() { this = "secKeyConfig" }

  override predicate isSource(DataFlow2::Node source) {
    source.asExpr() instanceof StrConst
  }

  override predicate isSink(DataFlow2::Node sink) {
    sink = Flask::FlaskApp::instance().getMember("config").getSubscript("SECRET_KEY").getAValueReachingSink()
    or sink = Flask::FlaskApp::instance().getMember("secret_key").getAValueReachingSink()
  }
}

from DataFlow2::PathNode source, DataFlow2::PathNode sink, SecKeyConfig config
where config.hasFlowPath(source, sink)
select source, sink, source.getNode().getLocation(), sink.getNode().getLocation(), "The secret key is a hardcoded string"
*/

string output(StrConst key) {
  // approximately 1 byte per char and recommended length for SHA1 is 24 bytes
  if key.getS().length() < 24
  then result = "The secret key is a hardcoded string and it's too short"
  else result = "The secret key is a hardcoded string"
}

// It's already interprocedural and takes into account dataflow between variables
from DataFlow::Node node
where (node = Flask::FlaskApp::instance().getMember("config").getSubscript("SECRET_KEY").getAValueReachingSink()
  or node = Flask::FlaskApp::instance().getMember("secret_key").getAValueReachingSink())
  and node.asExpr() instanceof StrConst
select node.getLocation(), output(node.asExpr())
