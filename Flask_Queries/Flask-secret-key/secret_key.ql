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

// TODO check the whole supertype chain (have to use recursion, it's probably better to only check the direct supertypes, which is what the query currently does, and ignore the rest of the chain because it would make the evaluation much slower and it would just catch a couple more cases (they are corner cases, not used as much))
bindingset[main, suf]
int sufcalc(string main, string suf) {
  result = main.length() - suf.length()
}

string output2(Expr seckey) {
  if seckey.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

/*
from DataFlow::Node node, Class cls, Variable v, AssignStmt asgn
where (node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getParameter(0).getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
  and (node.asExpr().(StrConst).getS().suffix(sufcalc(node.asExpr().(StrConst).getS(), cls.getName())) = cls.getName()
    or node.asExpr().(BinaryExpr).getASubExpression().(StrConst).getS().suffix(sufcalc(node.asExpr().(BinaryExpr).getASubExpression().(StrConst).getS(), cls.getName())) = cls.getName()
    or node.asCfgNode() = cls.getClassObject().getACall()
    or node.asExpr().(ClassExpr).getName() = cls.getName())
  and (asgn = cls.getClassObject().getASuperType().getPyClass().getAStmt().(AssignStmt)
    or asgn = cls.getAStmt().(AssignStmt))
  and asgn.defines(v)
  and asgn.getValue() instanceof StrConst
  and v.getId() = "SECRET_KEY"
select node, node.getLocation(), cls, cls.getLocation(), cls.getName(), v.getId(), v.getScope().getLocation(), output2(asgn.getValue())
*/

from DataFlow::Node node, Class cls, Variable v, AssignStmt asgn, Module mod
where (node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getParameter(0).getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
  and node.asExpr().(ImportMember).getImportedModuleName() = mod.getAnImportedModuleName()
select node, node.getLocation(), mod

/* This works
from DataFlow::Node node, AssignStmt asg
where (node = Flask::FlaskApp::instance().getMember("config").getMember("from_pyfile").getParameter(0).getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("from_pyfile").getKeywordParameter("obj").getAValueReachingSink())
  and exists(Variable v, AssignStmt asgn | 
    asgn.defines(v)
    and asgn.getValue() instanceof StrConst
    and v.getId() = "SECRET_KEY"
    and asgn.getLocation().getFile().getRelativePath().suffix(sufcalc(asgn.getLocation().getFile().getRelativePath(), node.asExpr().(StrConst).getS())) = node.asExpr().(StrConst).getS()
    and asgn = asg)
select node, node.getLocation(), asg.getLocation(), asg.getLocation().getFile().getRelativePath()
*/
