import python
import CodeQL_Library.FlaskLogin
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

/*
string output2(Expr node, Expr value) {
  if node instanceof StrConst
  then if node.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
  else if value.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}
*/

// approximately 1 byte per char and recommended length for SHA1 is 24 bytes
string output(Expr seckey) {
  if seckey.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

from Expr expr
where expr = FlaskLogin::getConfigValue("SECRET_KEY", "secret_key")
  and expr instanceof StrConst
select expr, expr.getLocation(), output(expr), expr.(StrConst).getS()

/* This works, it's already interprocedural and takes into account dataflow between variables (updating config directly or with a dictionary)
from DataFlow::Node node, KeyValuePair kv
where ((node = Flask::FlaskApp::instance().getMember("config").getSubscript("SECRET_KEY").getAValueReachingSink()
  or node = Flask::FlaskApp::instance().getMember("secret_key").getAValueReachingSink()
  or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("SECRET_KEY").getAValueReachingSink())
  and node.asExpr() instanceof StrConst)
  or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
  and kv = node.asExpr().(Dict).getAnItem()
  and kv.getKey().(Str).getText() = "SECRET_KEY"
  and kv.getValue() instanceof StrConst)
select node.getLocation(), output2(node.asExpr(), kv.getValue())
*/

/* This works (from_object no module import)
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
select node, node.getLocation(), cls, cls.getLocation(), cls.getName(), v.getId(), v.getScope().getLocation(), output(asgn.getValue())
*/

/* This works (from_object only module import)
from DataFlow::Node node, Class cls, Variable v, AssignStmt asgn, Function f
where (node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getParameter(0).getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
  and ((cls.getName() = node.asExpr().(ImportMember).getName()
      and exists(cls.getLocation().getFile().getRelativePath().indexOf(node.asExpr().(ImportMember).getImportedModuleName().splitAt("."))))
    or (f.getName() = node.asExpr().(ImportMember).getName()
      and exists(f.getLocation().getFile().getRelativePath().indexOf(node.asExpr().(ImportMember).getImportedModuleName().splitAt(".")))
      and f.getAnExitNode() = cls.getClassObject().getACall()))
select node, node.getLocation(), cls, cls.getLocation()
*/

/* This works (from_pyfile)
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
