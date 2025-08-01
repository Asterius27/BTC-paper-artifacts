import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

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

    Expr getConfigValueFromObject(string config_name, API::Node config) {
        exists(DataFlow::Node node, Class cls, Variable v, AssignStmt asgn | 
            (node = config.getMember("from_object").getParameter(0).getAValueReachingSink()
                or node = config.getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
            and (cls = getConfigClassNoModules(node)
                or cls = getConfigClassOnlyModules(node))
            and (asgn = cls.getClassObject().getASuperType().getPyClass().getAStmt().(AssignStmt)
                or asgn = cls.getAStmt().(AssignStmt))
            and asgn.defines(v)
            and v.getId() = config_name
            and result = asgn.getValue())
    }

    Expr getConfigValueFromObjectFile(string config_name, API::Node config) {
        exists(DataFlow::Node node, AssignStmt asg | 
            (node = config.getMember("from_object").getParameter(0).getAValueReachingSink()
                or node = config.getMember("from_object").getKeywordParameter("obj").getAValueReachingSink())
            and exists(Variable v, AssignStmt asgn | 
                asgn.defines(v)
                and v.getId() = config_name
                and exists(asgn.getLocation().getFile().getRelativePath().indexOf(node.asExpr().(StrConst).getS().splitAt(".")))
                and asgn = asg)
            and result = asg.getValue())
    }

    Expr getConfigValueFromPyFile(string config_name, API::Node config) {
        exists(DataFlow::Node node, AssignStmt asg | 
            (node = config.getMember("from_pyfile").getParameter(0).getAValueReachingSink()
                or node = config.getMember("from_pyfile").getKeywordParameter("filename").getAValueReachingSink())
            and exists(Variable v, AssignStmt asgn | 
                asgn.defines(v)
                and v.getId() = config_name
                and asgn.getLocation().getFile().getRelativePath().suffix(sufcalc(asgn.getLocation().getFile().getRelativePath(), node.asExpr().(StrConst).getS())) = node.asExpr().(StrConst).getS()
                and asgn = asg)
            and result = asg.getValue())
    }

    bindingset[config_name]
    Expr getConfigValueFromAssignment(string config_name, API::Node config) {
        exists(DataFlow::Node node | 
            (node = config.getSubscript(config_name).getAValueReachingSink()
                or node = config.getMember("update").getKeywordParameter(config_name).getAValueReachingSink())
            and result = node.asExpr())
    }

    Expr getConfigValueFromAttribute(string attribute_name) {
        exists(DataFlow::Node node | 
            node = Flask::FlaskApp::instance().getMember(attribute_name).getAValueReachingSink()
            and result = node.asExpr())
    }

    Expr getConfigValueFromDictionary(string config_name, API::Node config) {
        exists(DataFlow::Node node, KeyValuePair kv | 
            node = config.getMember("update").getParameter(0).getAValueReachingSink()
            and kv = node.asExpr().(Dict).getAnItem()
            and kv.getKey().(Str).getText() = config_name
            and result = kv.getValue())
    }

    bindingset[config_name]
    Expr getConfigValue(string config_name) {
        exists(Expr expr, API::Node config | 
            config = Flask::FlaskApp::instance().getMember("config")
            and (expr = getConfigValueFromObject(config_name, config)
                or expr = getConfigValueFromObjectFile(config_name, config)
                or expr = getConfigValueFromPyFile(config_name, config)
                or expr = getConfigValueFromAssignment(config_name, config)
                or expr = getConfigValueFromDictionary(config_name, config))
            and result = expr)
    }

    bindingset[config_name, attribute_name]
    Expr getConfigValue(string config_name, string attribute_name) {
        exists(Expr expr | 
            (expr = getConfigValue(config_name)
                or expr = getConfigValueFromAttribute(attribute_name))
            and result = expr)
    }

    DataFlow::Node getConfigSourceFromAttribute(string attribute_name) {
        result = Flask::FlaskApp::instance().getMember(attribute_name).getAValueReachableFromSource()
    }

    bindingset[config_name]
    DataFlow::Node getConfigSource(string config_name) {
        exists(API::Node config | 
            config = Flask::FlaskApp::instance().getMember("config")
            and (exists(getConfigValueFromObject(config_name, config))
                or exists(getConfigValueFromObjectFile(config_name, config))
                or exists(getConfigValueFromPyFile(config_name, config))
                or exists(getConfigValueFromAssignment(config_name, config))
                or exists(getConfigValueFromDictionary(config_name, config)))
            and result = config.getAValueReachableFromSource())
    }

    bindingset[config_name, attribute_name]
    DataFlow::Node getConfigSource(string config_name, string attribute_name) {
        exists(DataFlow::Node node | 
            (node = getConfigSource(config_name)
                or node = getConfigSourceFromAttribute(attribute_name))
            and result = node)
    }

    predicate configSetFromEnvVar(Expr value) {
        exists(DataFlow::Node env | 
            (env = API::moduleImport("os").getMember("getenv").getACall()
                or env = API::moduleImport("os").getMember("environ").getASubscript().getAValueReachableFromSource()
                or env = API::moduleImport("os").getMember("environ").getMember("get").getAValueReachableFromSource()
                or env = API::moduleImport("environs").getMember("Env").getReturn().getACall()
                or env = API::moduleImport("environs").getMember("Env").getReturn().getAMember().getACall())
            and exists(env.getLocation().getFile().getRelativePath())
            and exists(value.getLocation().getFile().getRelativePath())
            and value.getAFlowNode() = env.asCfgNode())
    }

    bindingset[config_name]
    Expr getConfigSinkFromEnvVar(string config_name) {
        exists(Expr value | 
            value = getConfigValue(config_name)
            and configSetFromEnvVar(value)
            and result = value)
    }

    bindingset[config_name, attribute_name]
    Expr getConfigSinkFromEnvVar(string config_name, string attribute_name) {
        exists(Expr value | 
            value = getConfigValue(config_name, attribute_name)
            and configSetFromEnvVar(value)
            and result = value)
    }

    DataFlow::Node getConfigSourceFromEnvFile() {
        result = Flask::FlaskApp::instance().getMember("config").getMember("from_envvar").getAValueReachableFromSource()
        or result = Flask::FlaskApp::instance().getMember("config").getMember("from_prefixed_env").getAValueReachableFromSource()
    }

    DataFlow::Node getConfigSourceFromFile() {
        result = Flask::FlaskApp::instance().getMember("config").getMember("from_file").getAValueReachableFromSource()
    }

    DataFlow::Node getConfigSourceFromMapping() {
        result = Flask::FlaskApp::instance().getMember("config").getMember("from_mapping").getAValueReachableFromSource()
    }

    DataFlow::Node getConfigSourceFromKeys() {
        result = Flask::FlaskApp::instance().getMember("config").getMember("fromkeys").getAValueReachableFromSource()
    }

    predicate formClass(Class cls) {
        exists(cls.getLocation().getFile().getRelativePath())
        and (cls.getABase().toString() = "Form"
            or cls.getABase().toString() = "BaseForm"
            or cls.getABase().toString() = "FlaskForm")
    }

    predicate classWithPasswordField(Class cls) {
        exists(API::Node node | 
            (node = API::moduleImport("wtforms").getMember("PasswordField")
                or node = API::moduleImport("flask_wtf").getMember("PasswordField"))
            and cls.getAStmt().(AssignStmt).getValue().(Call).getFunc() = node.getAValueReachableFromSource().asExpr())
    }

    Class getSignUpFormClass() {
        exists(Class cls, Class supercls |
            if exists(Class superclss | superclss.getName() = cls.getABase().(Name).getId())
            then supercls.getName() = cls.getABase().(Name).getId()
                and (formClass(cls)
                    or formClass(supercls))
                and (classWithPasswordField(cls)
                    or classWithPasswordField(supercls))
                and (cls.getName().toLowerCase().matches("%registration%")
                    or cls.getName().toLowerCase().matches("%register%")
                    or cls.getName().toLowerCase().matches("%createaccount%")
                    or cls.getName().toLowerCase().matches("%signup%")
                    or cls.getName().toLowerCase().matches("%adduser%")
                    or cls.getName().toLowerCase().matches("%useradd%")
                    or cls.getName().toLowerCase().matches("%regform%")
                    or cls.getName().toLowerCase().matches("%newuser%")
                    or cls.getName().toLowerCase().matches("%userform%")
                    or cls.getName().toLowerCase().matches("%usersform%")
                    or cls.getName().toLowerCase().matches("%registform%"))
                and result = cls
            else formClass(cls)
                and classWithPasswordField(cls)
                and (cls.getName().toLowerCase().matches("%registration%")
                    or cls.getName().toLowerCase().matches("%register%")
                    or cls.getName().toLowerCase().matches("%createaccount%")
                    or cls.getName().toLowerCase().matches("%signup%")
                    or cls.getName().toLowerCase().matches("%adduser%")
                    or cls.getName().toLowerCase().matches("%useradd%")
                    or cls.getName().toLowerCase().matches("%regform%")
                    or cls.getName().toLowerCase().matches("%newuser%")
                    or cls.getName().toLowerCase().matches("%userform%")
                    or cls.getName().toLowerCase().matches("%usersform%")
                    or cls.getName().toLowerCase().matches("%registform%"))
                and result = cls)
    }

    string getPasswordFieldName(Class cls) {
        exists(DataFlow::Node node | 
            (node = API::moduleImport("wtforms").getMember("PasswordField").getReturn().getAValueReachableFromSource()
                or node = API::moduleImport("flask_wtf").getMember("PasswordField").getReturn().getAValueReachableFromSource())
            and cls.getBody().contains(node.asCfgNode().getNode())
            and result = node.asExpr().(Name).toString())
    }

    Class getClassViews() {
        exists(Class cls, DataFlow::Node node |
            (node = API::moduleImport("flask").getMember("views").getMember("View").getAValueReachableFromSource()
                or node = API::moduleImport("flask").getMember("views").getMember("MethodView").getAValueReachableFromSource())
            and cls.getABase() = node.asExpr()
            and result = cls)
    }
    
    Function getFunctionViews() {
        exists(Function f |
            (f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "route"
                or f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "get"
                or f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "post"
                or f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "put"
                or f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "delete"
                or f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "patch"
                or f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "options"
                or f.getADecorator().(Call).getFunc().(Attribute).getAttr() = "head")
            and result = f)
    }
}
