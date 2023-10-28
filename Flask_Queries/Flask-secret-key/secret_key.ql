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

// approximately 1 byte per char and recommended length for SHA1 is 24 bytes
string output(Expr node, Expr value) {
  if node instanceof StrConst
  then if node.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
  else if value.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

/* It's already interprocedural and takes into account dataflow between variables
from DataFlow::Node node, KeyValuePair kv
where ((node = Flask::FlaskApp::instance().getMember("config").getSubscript("SECRET_KEY").getAValueReachingSink()
  or node = Flask::FlaskApp::instance().getMember("secret_key").getAValueReachingSink()
  or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("SECRET_KEY").getAValueReachingSink())
  and node.asExpr() instanceof StrConst)
  or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
  and kv = node.asExpr().(Dict).getAnItem()
  and kv.getKey().(Str).getText() = "SECRET_KEY"
  and kv.getValue() instanceof StrConst)
select node.getLocation(), output(node.asExpr(), kv.getValue())
*/

from DataFlow::Node node, Class cls
where node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getParameter(0).getAValueReachingSink()
  and (node.asExpr().(Str).suffix(node.asExpr().(Str).length() - cls.getName().length()) = cls.getName()
    or node.asExpr().(BinaryExpr).getASubExpression().(Str).matches("%" + cls.getName().toString()))
  // and cls.getName() = "ConfigClass"
  // or node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getKeywordParameter("obj").getAValueReachingSink()
select node, node.getLocation(), cls, cls.getLocation(), cls.getName()
