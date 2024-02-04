import python
import semmle.python.ApiGraphs

module DjangoSession {

    class RequestObjectConfiguration extends DataFlow::Configuration {
        RequestObjectConfiguration() { this = "RequestObjectConfiguration" }
    
        override predicate isSource(DataFlow::Node source) {
            (source.asExpr() = DjangoSession::getARequestObjectFromClassViews()
                or source.asExpr() = DjangoSession::getARequestObjectFromFunctionViews())
            and exists(source.getLocation().getFile().getRelativePath())
        }
    
        override predicate isSink(DataFlow::Node sink) {
            exists(Attribute atr | 
                atr.getName() = "user"
                and atr.getObject() = sink.asExpr()
                and exists(sink.getLocation().getFile().getRelativePath()))
        }
    }

    Parameter getARequestObjectFromFunctionViews() {
        exists(Function f, AssignStmt asgn, Expr name, Keyword k |
            (name = asgn.getValue().(List).getAnElt().(Call).getPositionalArg(1)
                or (k = asgn.getValue().(List).getAnElt().(Call).getANamedArg().(Keyword)
                    and name = k.getValue()
                    and k.getArg() = "view"))
            and asgn.getATarget().toString() = "urlpatterns"
            and f.getName() = name.(Attribute).getName()
            and exists(name.getLocation().getFile().getRelativePath())
            and result = f.getArg(0))
    }

    Parameter getARequestObjectFromClassViews() {
        exists(AssignStmt asgn, Expr name, Keyword k, Class cls | 
            (name = asgn.getValue().(List).getAnElt().(Call).getPositionalArg(1)
                or (k = asgn.getValue().(List).getAnElt().(Call).getANamedArg().(Keyword)
                    and name = k.getValue()
                    and k.getArg() = "view"))
            and asgn.getATarget().toString() = "urlpatterns"
            and (cls.getName() = name.(Call).getFunc().(Attribute).getObject().(Name).getId()
                or cls.getName() = name.(Call).getFunc().(Attribute).getObject().(Attribute).getName())
            and exists(name.getLocation().getFile().getRelativePath())
            and result = cls.getAMethod().getArg(1))
    }

    ControlFlowNode getAUserObject() {
        exists(DataFlow::Node src, DataFlow::Node sink, RequestObjectConfiguration config |
            config.hasFlow(src, sink)
            and result = sink.asCfgNode())
    }

    // TODO doesn't work
    ControlFlowNode getUserIsAuthenticatedAccess() {
        exists(Attribute atr |
            atr.getName() = "is_authenticated"
            and atr.getObject().getAFlowNode() = getAUserObject()
            and result = atr.getAFlowNode())
    }

}
