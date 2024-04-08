import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

bindingset[val, pos]
string getValue(ControlFlowNode cfg, string val, int pos) {
    if exists(cfg.(CallNode).getArgByName(val).inferredValue()) or exists(cfg.(CallNode).getArg(pos).inferredValue())
    then exists(Value value | 
        (value = cfg.(CallNode).getArgByName(val).inferredValue()
            or value = cfg.(CallNode).getArg(pos).inferredValue())
        and result = val + " value: " + value)
    else result = val + " value not set"
}

predicate isInsideSignUpForm(DataFlow::Node passfield) {
    exists(Class cls, Class supercls |
        cls = FlaskLogin::getSignUpFormClass()
        and if exists(Class superclss | superclss.getName() = cls.getABase().(Name).getId())
            then supercls.getName() = cls.getABase().(Name).getId()
                and (passfield.getScope() = cls
                    or passfield.getScope() = supercls)
            else passfield.getScope() = cls)
}

from DataFlow::Node node, ControlFlowNode validator
where (node = API::moduleImport("wtforms").getMember("PasswordField").getParameter(1).getAValueReachingSink()
        or node = API::moduleImport("flask_wtf").getMember("PasswordField").getParameter(1).getAValueReachingSink()
        or node = API::moduleImport("wtforms").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink()
        or node = API::moduleImport("flask_wtf").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink())
    and (validator = API::moduleImport("wtforms").getMember("validators").getMember("Length").getReturn().getAValueReachableFromSource().asCfgNode()
        or validator = API::moduleImport("wtforms").getMember("validators").getMember("length").getReturn().getAValueReachableFromSource().asCfgNode())
    and (node.asExpr().(List).getAnElt().getAFlowNode() = validator
        or node.asExpr().(Tuple).getAnElt().getAFlowNode() = validator)
    and isInsideSignUpForm(node)
select node, node.getLocation(), "Length checks are being performed on the password field", getValue(validator, "max", 1), getValue(validator, "min", 0)
