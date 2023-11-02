import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO check the whole supertype chain (have to use recursion, it's probably better to only check the direct supertypes, which is what the query currently does, and ignore the rest of the chain because it would make the evaluation much slower and it would just catch a couple more cases (they are corner cases, not used as much))
// TODO .getValue() is not intra nor interprocedural
bindingset[main, suf]
int sufcalc(string main, string suf) {
  result = main.length() - suf.length()
}

Class getConfigClassNoModules(DataFlow::Node node) {
  exists(Class cls | 
    (node.asExpr().(StrConst).getS().suffix(sufcalc(node.asExpr().(StrConst).getS(), cls.getName())) = cls.getName()
      or node.asExpr().(BinaryExpr).getASubExpression().(StrConst).getS().suffix(sufcalc(node.asExpr().(BinaryExpr).getASubExpression().(StrConst).getS(), cls.getName())) = cls.getName()
      or node.asCfgNode() = cls.getClassObject().getACall()
      or node.asExpr().(ClassExpr).getName() = cls.getName())
    and result = cls)
}

Class getConfigClassOnlyModules(DataFlow::Node node) {
  exists(Class cls, Function f | 
    ((cls.getName() = node.asExpr().(ImportMember).getName()
        and exists(cls.getLocation().getFile().getRelativePath().indexOf(node.asExpr().(ImportMember).getImportedModuleName().splitAt("."))))
      or (f.getName() = node.asExpr().(ImportMember).getName()
        and exists(f.getLocation().getFile().getRelativePath().indexOf(node.asExpr().(ImportMember).getImportedModuleName().splitAt(".")))
        and f.getAnExitNode() = cls.getClassObject().getACall()))
    and result = cls)
}

Expr getConfigValueFromObject(string config_name) {
  exists(DataFlow::Node node, Class cls, Variable v, AssignStmt asgn | 
    (node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getParameter(0).getAValueReachingSink()
      or node = Flask::FlaskApp::instance().getMember("config").getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
    and (cls = getConfigClassNoModules(node)
      or cls = getConfigClassOnlyModules(node))
    and (asgn = cls.getClassObject().getASuperType().getPyClass().getAStmt().(AssignStmt)
      or asgn = cls.getAStmt().(AssignStmt))
    and asgn.defines(v)
    and v.getId() = config_name
    and result = asgn.getValue())
}

Expr getConfigValueFromPyFile(string config_name) {
  exists(DataFlow::Node node, AssignStmt asg | 
    (node = Flask::FlaskApp::instance().getMember("config").getMember("from_pyfile").getParameter(0).getAValueReachingSink()
      or node = Flask::FlaskApp::instance().getMember("config").getMember("from_pyfile").getKeywordParameter("filename").getAValueReachingSink())
    and exists(Variable v, AssignStmt asgn | 
      asgn.defines(v)
      and v.getId() = config_name
      and asgn.getLocation().getFile().getRelativePath().suffix(sufcalc(asgn.getLocation().getFile().getRelativePath(), node.asExpr().(StrConst).getS())) = node.asExpr().(StrConst).getS()
      and asgn = asg)
    and result = asg.getValue())
}

bindingset[config_name]
Expr getConfigValue(string config_name) {
  exists(DataFlow::Node node | 
    (node = Flask::FlaskApp::instance().getMember("config").getSubscript(config_name).getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter(config_name).getAValueReachingSink())
    and result = node.asExpr())
}

Expr getConfigValueFromDictionary(string config_name) {
  exists(DataFlow::Node node, KeyValuePair kv | 
    node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
    and kv = node.asExpr().(Dict).getAnItem()
    and kv.getKey().(Str).getText() = config_name
    and result = kv.getValue())
}

predicate valueCheck(Expr expr) {
    expr.toString() != "None"
}

where not exists(Expr expr | 
  (expr = getConfigValueFromObject("SESSION_COOKIE_SAMESITE")
    or expr = getConfigValueFromPyFile("SESSION_COOKIE_SAMESITE")
    or expr = getConfigValue("SESSION_COOKIE_SAMESITE")
    or expr = getConfigValueFromDictionary("SESSION_COOKIE_SAMESITE"))
  and valueCheck(expr))
select "Session cookie samesite attribute is disabled or not set (the default value is disabled)"

/* TODO might want to check if session cookies are disabled as part of the query
// TODO intraprocedural version of the query
// dataflow analysis works also with "pointers" (references) and it's interprocedural (it takes into account dataflow between variables and functions)
// of course it doesn't detect values that are know only at runtime (such as environment variables)
where not exists(DataFlow::Node node, KeyValuePair kv | 
    ((node = Flask::FlaskApp::instance().getMember("config").getSubscript("SESSION_COOKIE_SAMESITE").getAValueReachingSink()
    or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("SESSION_COOKIE_SAMESITE").getAValueReachingSink())
    and node.asExpr().toString() != "None")
    or (node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
    and kv = node.asExpr().(Dict).getAnItem()
    and kv.getKey().(Str).getText() = "SESSION_COOKIE_SAMESITE"
    and kv.getValue().toString() != "None"))
select "Session cookie samesite attribute is disabled or not set (the default value is disabled)"
*/
