import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

string getRegexp(ControlFlowNode validator) {
    if exists(validator.(CallNode).getArgByName("regex").inferredValue()) or exists(validator.(CallNode).getArg(0).inferredValue())
    then exists(Value regexp | 
        (regexp = validator.(CallNode).getArgByName("regex").inferredValue()
            or regexp = validator.(CallNode).getArg(0).inferredValue())
        and result = "The regex being used is: " + regexp)
    else result = "Either the regexp is not set or it is not a string"
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
    and (validator = API::moduleImport("wtforms").getMember("validators").getMember("Regexp").getReturn().getAValueReachableFromSource().asCfgNode()
        or validator = API::moduleImport("wtforms").getMember("validators").getMember("regexp").getReturn().getAValueReachableFromSource().asCfgNode())
    and (node.asExpr().(List).getAnElt().getAFlowNode() = validator
        or node.asExpr().(Tuple).getAnElt().getAFlowNode() = validator)
    and isInsideSignUpForm(node)
select node, node.getLocation(), "The password is being checked using a regexp", getRegexp(validator)
