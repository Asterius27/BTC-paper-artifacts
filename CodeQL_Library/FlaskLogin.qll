import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// TODO check the whole supertype chain (have to use recursion, it's probably better to only check the direct supertypes, which is what the query currently does, and ignore the rest of the chain because it would make the evaluation much slower and it would just catch a couple more cases (they are corner cases, not used as much))
// TODO .getValue() is not intra nor interprocedural
module FlaskLogin {
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
    Expr getConfigValueFromAssignment(string config_name) {
        exists(DataFlow::Node node | 
            (node = Flask::FlaskApp::instance().getMember("config").getSubscript(config_name).getAValueReachingSink()
                or node = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter(config_name).getAValueReachingSink())
            and result = node.asExpr())
    }

    Expr getConfigValueFromAttribute(string attribute_name) {
        exists(DataFlow::Node node | 
            node = Flask::FlaskApp::instance().getMember(attribute_name).getAValueReachingSink()
            and result = node.asExpr())
    }

    Expr getConfigValueFromDictionary(string config_name) {
        exists(DataFlow::Node node, KeyValuePair kv | 
            node = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).getAValueReachingSink()
            and kv = node.asExpr().(Dict).getAnItem()
            and kv.getKey().(Str).getText() = config_name
            and result = kv.getValue())
    }

    bindingset[config_name]
    Expr getConfigValue(string config_name) {
        exists(Expr expr | 
            (expr = getConfigValueFromObject(config_name)
                or expr = getConfigValueFromPyFile(config_name)
                or expr = getConfigValueFromAssignment(config_name)
                or expr = getConfigValueFromDictionary(config_name))
            and result = expr)
    }

    bindingset[config_name, attribute_name]
    Expr getConfigValue(string config_name, string attribute_name) {
        exists(Expr expr | 
            (expr = getConfigValue(config_name)
                or expr = getConfigValueFromAttribute(attribute_name))
            and result = expr)
    }

    // TODO all of the following functions can be refactored to improve code reuse (pass config to the previously defined functions and check if they return a value or not (exists))
    DataFlow::Node getConfigSourceFromObject(string config_name) {
        exists(DataFlow::Node node, Class cls, Variable v, AssignStmt asgn, API::Node config | 
            config = Flask::FlaskApp::instance().getMember("config")
            and (node = config.getMember("from_object").getParameter(0).getAValueReachingSink()
                or node = config.getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
            and (cls = getConfigClassNoModules(node)
                or cls = getConfigClassOnlyModules(node))
            and (asgn = cls.getClassObject().getASuperType().getPyClass().getAStmt().(AssignStmt)
                or asgn = cls.getAStmt().(AssignStmt))
            and asgn.defines(v)
            and v.getId() = config_name
            and result = config.getAValueReachableFromSource())
    }

    DataFlow::Node getConfigSourceFromPyFile(string config_name) {
        exists(DataFlow::Node node, AssignStmt asg, API::Node config | 
            config = Flask::FlaskApp::instance().getMember("config")
            and (node = config.getMember("from_pyfile").getParameter(0).getAValueReachingSink()
                or node = config.getMember("from_pyfile").getKeywordParameter("filename").getAValueReachingSink())
            and exists(Variable v, AssignStmt asgn | 
                asgn.defines(v)
                and v.getId() = config_name
                and asgn.getLocation().getFile().getRelativePath().suffix(sufcalc(asgn.getLocation().getFile().getRelativePath(), node.asExpr().(StrConst).getS())) = node.asExpr().(StrConst).getS()
                and asgn = asg)
            and result = config.getAValueReachableFromSource())
    }

    bindingset[config_name]
    DataFlow::Node getConfigSourceFromAssignment(string config_name) {
        exists(API::Node config | 
            config = Flask::FlaskApp::instance().getMember("config")
            and (exists(config.getSubscript(config_name).getAValueReachingSink())
                or exists(config.getMember("update").getKeywordParameter(config_name).getAValueReachingSink()))
            and result = config.getAValueReachableFromSource())
    }

    DataFlow::Node getConfigSourceFromAttribute(string attribute_name) {
        result = Flask::FlaskApp::instance().getMember(attribute_name).getAValueReachableFromSource()
    }

    DataFlow::Node getConfigSourceFromDictionary(string config_name) {
        exists(DataFlow::Node node, API::Node config, KeyValuePair kv | 
            config = Flask::FlaskApp::instance().getMember("config")
            and node = config.getMember("update").getParameter(0).getAValueReachingSink()
            and kv = node.asExpr().(Dict).getAnItem()
            and kv.getKey().(Str).getText() = config_name
            and result = config.getAValueReachableFromSource())
    }

    bindingset[config_name]
    DataFlow::Node getConfigSource(string config_name) {
        exists(DataFlow::Node node | 
            (node = getConfigSourceFromObject(config_name)
                or node = getConfigSourceFromPyFile(config_name)
                or node = getConfigSourceFromAssignment(config_name)
                or node = getConfigSourceFromDictionary(config_name))
            and result = node)
    }

    bindingset[config_name, attribute_name]
    DataFlow::Node getConfigSource(string config_name, string attribute_name) {
        exists(DataFlow::Node node | 
            (node = getConfigSource(config_name)
                or node = getConfigSourceFromAttribute(attribute_name))
            and result = node)
    }
}
