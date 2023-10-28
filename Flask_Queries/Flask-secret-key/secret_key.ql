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

// TODO also catch the case when an object is passed to the config.from_object(), also if the variable is set in a superclass the query won't work
bindingset[main, suf]
int sufcalc(string main, string suf) {
  result = main.length() - suf.length()
}

string output2(Expr seckey) {
  if seckey.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

from DataFlow::Node node, Class cls, Variable v, AssignStmt asgn
where (node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getParameter(0).getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
  and (node.asExpr().(StrConst).getS().suffix(sufcalc(node.asExpr().(StrConst).getS(), cls.getName())) = cls.getName()
    or node.asExpr().(BinaryExpr).getASubExpression().(StrConst).getS().suffix(sufcalc(node.asExpr().(BinaryExpr).getASubExpression().(StrConst).getS(), cls.getName())) = cls.getName())
  and asgn = cls.getAStmt().(AssignStmt)
  and asgn.defines(v)
  and asgn.getValue() instanceof StrConst
  and v.getId() = "SECRET_KEY"
select node, node.getLocation(), cls, cls.getLocation(), cls.getName(), v.getId(), output2(asgn.getValue())
