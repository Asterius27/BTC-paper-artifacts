import python
import semmle.python.ApiGraphs
import CodeQL_Library.FlaskLogin

string getRegexp(API::Node validator) {
    if exists(validator.getKeywordParameter("regex").getAValueReachingSink().asExpr().(StrConst).getS()) or exists(validator.getParameter(0).getAValueReachingSink().asExpr().(StrConst).getS())
    then exists(Expr regexp | 
        (regexp = validator.getKeywordParameter("regex").getAValueReachingSink().asExpr()
            or regexp = validator.getParameter(0).getAValueReachingSink().asExpr())
        and result = "The regex being used is: " + regexp.(StrConst).getS())
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

from DataFlow::Node node, API::Node validator
where (node = API::moduleImport("wtforms").getMember("PasswordField").getParameter(1).getAValueReachingSink()
        or node = API::moduleImport("flask_wtf").getMember("PasswordField").getParameter(1).getAValueReachingSink()
        or node = API::moduleImport("wtforms").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink()
        or node = API::moduleImport("flask_wtf").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink())
    and (validator = API::moduleImport("wtforms").getMember("validators").getMember("Regexp")
        or validator = API::moduleImport("wtforms").getMember("validators").getMember("regexp"))
    and (node.asExpr().(List).getAnElt().getAFlowNode() = validator.getReturn().getAValueReachableFromSource().asCfgNode()
        or node.asExpr().(Tuple).getAnElt().getAFlowNode() = validator.getReturn().getAValueReachableFromSource().asCfgNode())
    and isInsideSignUpForm(node)
select node, node.getLocation(), "The password is being checked using a regexp", getRegexp(validator)
