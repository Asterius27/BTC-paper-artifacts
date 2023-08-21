import python
import semmle.python.frameworks.Flask
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.DataFlow2

// This only works if the developers adds the hsts header to every response, by using the after_request decorator (provided by flask)
// TODO finish the intraprocedural version
/* This is intraprocedural
from Function f, Parameter p, Attribute a, Subscript s, StrConst str
where f.getADecorator() = Flask::FlaskApp::instance().getMember("after_request").asSource().asExpr()
    and p = f.getArg(0)
    and p.getName() = a.getObject().toString()
    and a.getAttr() = "headers"
    and a.getAttr() = s.getObject().(Attribute).getAttr()
    and s.getIndex().(Str).getText() = "Strict-Transport-Security"
    and str.getText() = "max-age=31536000; includeSubDomains" // TODO only need to check that it starts with max-age=
    and DataFlow::localFlow(DataFlow::exprNode(str), DataFlow::exprNode(s)) // TODO doesn't work
select f.getName(), f.getLocation(), p.getName(), p.getLocation(), a.getName(), a.getObject().toString(), a.getLocation(), s.getIndex().(Str).getText(), s.getLocation(), s.getValue(), str.getLocation()
*/

/* This works
from Subscript s
where exists(s.getLocation().getFile().getRelativePath())
select s.getObject().(Attribute).getAttr(), s.getLocation()
*/

/* This works
from StrConst str
where str.getText() = "max-age=31536000; includeSubDomains"
select str.getLocation()
*/

class HSTSConfiguration extends DataFlow::Configuration {
    HSTSConfiguration() { this = "HSTSConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        // 1 = 1
        /*
        exists(AssignStmt asgn | 
            asgn.getValue().(Str).getText().prefix(8) = "max-age="
            and asgn.getATarget().getAFlowNode() = source.asCfgNode())
        */
        source.asExpr() instanceof Str
        and source.asExpr().(Str).getText().prefix(8) = "max-age="
        and exists(source.asExpr().(Str).getText().indexOf("includeSubDomains"))
    }

    override predicate isSink(DataFlow::Node sink) {
        // 1 = 1
        exists(AssignStmt asgn, Subscript s, Attribute a | 
            s.getIndex().(Str).getText() = "Strict-Transport-Security"
            and a.getAttr() = "headers"
            and a.getAttr() = s.getObject().(Attribute).getAttr()
            and asgn.getATarget() = s
            and asgn.getValue().getAFlowNode() = sink.asCfgNode())
        /*
        sink.asExpr() instanceof Attribute
        and sink.asExpr().(Attribute).getAttr() = "headers"
        and exists(Subscript s |
            s.getIndex().(Str).getText() = "Strict-Transport-Security"
            and sink.asExpr().(Attribute).getAttr() = s.getObject().(Attribute).getAttr())
        */
        /*
        sink.asExpr() instanceof Subscript
        and sink.asExpr().(Subscript).getIndex().(Str).getText() = "Strict-Transport-Security"
        and exists(Attribute a | 
            a.getAttr() = "headers"
            and a.getAttr() = sink.asExpr().(Subscript).getObject().(Attribute).getAttr())
        */
    }
}

class HSTSConfiguration2 extends DataFlow2::Configuration {
    HSTSConfiguration2() { this = "HSTSConfiguration2" }

    override predicate isSource(DataFlow2::Node source) {
        exists(AssignStmt asgn, Subscript s, Attribute a | 
            s.getIndex().(Str).getText() = "Strict-Transport-Security"
            and a.getAttr() = "headers"
            and a.getAttr() = s.getObject().(Attribute).getAttr()
            and asgn.getATarget() = s
            and asgn.getValue().getAFlowNode() = source.asCfgNode())
    }

    override predicate isSink(DataFlow2::Node sink) {
        exists(Function f |
            f.getADecorator() = Flask::FlaskApp::instance().getMember("after_request").asSource().asExpr()
            and f = sink.getScope())
    }

    override predicate isAdditionalFlowStep(DataFlow2::Node fromNode, DataFlow2::Node toNode) {
        exists(Function f, Call c | 
            f = fromNode.getScope()
            and c.getFunc().toString() = f.getName()
            and c.getAFlowNode() = toNode.asCfgNode()
            and exists(c.getLocation().getFile().getRelativePath())
            and exists(f.getLocation().getFile().getRelativePath()))
    }
}
 
where not exists(DataFlow::Node source, DataFlow::Node sink, HSTSConfiguration config, DataFlow2::Node func, DataFlow2::Node node, HSTSConfiguration2 fconfig |
    config.hasFlow(source, sink)
    and sink = node
    and fconfig.hasFlow(node, func))
select "HSTS not activated (or misconfigured) or activated without the includeSubDomains option"

/* This works
from Function f, DataFlow2::Node sink
where f.getADecorator() = Flask::FlaskApp::instance().getMember("after_request").asSource().asExpr()
    and f = sink.getScope()
select sink, sink.getLocation(), f, f.getEntryNode().getLocation()
*/

/* This works
from AssignStmt asgn, DataFlow::Node node
where node.asExpr() instanceof Subscript
    and node.asExpr().(Subscript).getIndex().(Str).getText() = "Strict-Transport-Security"
    and exists(Attribute a | 
        a.getAttr() = "headers"
        and a.getAttr() = node.asExpr().(Subscript).getObject().(Attribute).getAttr())
    and asgn.getATarget().getAFlowNode() = node.asCfgNode()
select asgn.getValue(), asgn.getLocation(), asgn.getValue().getAFlowNode()
*/

/* This works
from AssignStmt asgn, DataFlow::Node node
where asgn.getValue().(Str).getText().prefix(8) = "max-age="
    and asgn.getATarget().getAFlowNode() = node.asCfgNode()
select node.getLocation(), node.asCfgNode()
*/

/* This works
from DataFlow::Node source
where source.asExpr() instanceof Str
    and source.asExpr().(Str).getText().prefix(8) = "max-age="
select source.getLocation()
*/

/* This works
from DataFlow::Node sink
where sink.asExpr() instanceof Subscript
    and sink.asExpr().(Subscript).getIndex().(Str).getText() = "Strict-Transport-Security"
    and exists(Attribute a | 
        a.getAttr() = "headers"
        and a.getAttr() = sink.asExpr().(Subscript).getObject().(Attribute).getAttr())
select sink.getLocation()
*/

/* This works
from DataFlow::Node sink
where sink.asExpr() instanceof Attribute
    and sink.asExpr().(Attribute).getAttr() = "headers" // (Subscript).getIndex().(Str).getText() = "Strict-Transport-Security"
    and exists(sink.getLocation().getFile().getRelativePath())
select sink.getLocation()
*/

/* This works
from DataFlow::Node source, Str str
where exists(source.getLocation().getFile().getRelativePath())
    and str.getText().prefix(8) = "max-age="
    and str.getAFlowNode() = source.asCfgNode()
select source, source.getLocation(), source.asExpr(), str.getLocation()
*/
