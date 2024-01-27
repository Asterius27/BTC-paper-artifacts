import python
import semmle.python.ApiGraphs

string getMinValue(API::Node validator) {
    if exists(validator.getKeywordParameter("min").getAValueReachingSink().asExpr().(IntegerLiteral).getValue()) or exists(validator.getParameter(0).getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
    then exists(Expr minvalue | 
        (minvalue = validator.getKeywordParameter("min").getAValueReachingSink().asExpr()
            or minvalue = validator.getParameter(0).getAValueReachingSink().asExpr())
        and result = "Min value: " + minvalue.(IntegerLiteral).getValue())
    else result = "Min value not set"
}

string getMaxValue(API::Node validator) {
    if exists(validator.getKeywordParameter("max").getAValueReachingSink().asExpr().(IntegerLiteral).getValue()) or exists(validator.getParameter(1).getAValueReachingSink().asExpr().(IntegerLiteral).getValue())
    then exists(Expr maxvalue | 
        (maxvalue = validator.getKeywordParameter("max").getAValueReachingSink().asExpr()
            or maxvalue = validator.getParameter(1).getAValueReachingSink().asExpr())
        and result = "Max value: " + maxvalue.(IntegerLiteral).getValue())
    else result = "Max value not set"
}

from DataFlow::Node node, API::Node validator
where (node = API::moduleImport("wtforms").getMember("PasswordField").getParameter(1).getAValueReachingSink()
        or node = API::moduleImport("flask_wtf").getMember("PasswordField").getParameter(1).getAValueReachingSink()
        or node = API::moduleImport("wtforms").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink()
        or node = API::moduleImport("flask_wtf").getMember("PasswordField").getKeywordParameter("validators").getAValueReachingSink())
    and (validator = API::moduleImport("wtforms").getMember("validators").getMember("Length")
        or validator = API::moduleImport("wtforms").getMember("validators").getMember("length"))
    and node.asExpr().(List).getAnElt().getAFlowNode() = validator.getReturn().getAValueReachableFromSource().asCfgNode()
select node, node.getLocation(), "Length checks are being performed on the password field", getMinValue(validator), getMaxValue(validator)
