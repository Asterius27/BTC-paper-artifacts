import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow3
import semmle.python.dataflow.new.DataFlow2

module DjangoSession {

    class RequestObjectConfiguration extends DataFlow::Configuration {
        RequestObjectConfiguration() { this = "RequestObjectConfiguration" }
    
        override predicate isSource(DataFlow::Node source) {
            (source.asExpr() = DjangoSession::getARequestObjectFromClassViews(1)
                or source.asExpr() = DjangoSession::getARequestObjectFromFunctionViews()
                or source.asExpr() = DjangoSession::getARequestObjectFromClassViewsUsingSelf())
            and exists(source.getLocation().getFile().getRelativePath())
        }
    
        override predicate isSink(DataFlow::Node sink) {
            exists(Attribute atr | 
                atr.getName() = "user"
                and atr.getObject() = sink.asExpr()
                and exists(sink.getLocation().getFile().getRelativePath()))
        }
    }

    // TODO there might be other ways to set the password hashers (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))
    class PasswordHashersConfiguration extends DataFlow3::Configuration {
        PasswordHashersConfiguration() { this = "PasswordHashersConfiguration" }

        override predicate isSource(DataFlow3::Node source) {
            exists(source.getLocation().getFile().getRelativePath())
            and (source.asExpr() instanceof List
                or source.asExpr() instanceof Tuple)
        }

        override predicate isSink(DataFlow3::Node sink) {
            exists(AssignStmt asgn, AugAssign augasgn, Name name | 
                name.getId() = "PASSWORD_HASHERS"
                and ((asgn.getATarget() = name
                    and exists(asgn.getLocation().getFile().getRelativePath())
                    and asgn.getValue().getAFlowNode() = sink.asCfgNode())
                or (augasgn.getTarget() = name
                    and exists(augasgn.getLocation().getFile().getRelativePath())
                    and augasgn.getValue().getAFlowNode() = sink.asCfgNode()))
            )
        }
    }

    class PasswordHashersListConfiguration extends DataFlow2::Configuration {
        PasswordHashersListConfiguration() { this = "PasswordHashersListConfiguration" }

        override predicate isSource(DataFlow2::Node source) {
            exists(source.getLocation().getFile().getRelativePath())
            and source.asExpr() instanceof StrConst
        }

        override predicate isSink(DataFlow2::Node sink) {
            exists(sink.getLocation().getFile().getRelativePath())
            and (exists(List lst | 
                lst.getElt(0) = sink.asExpr())
                or exists(Tuple lst | 
                    lst.getElt(0) = sink.asExpr()))
        }
    }

    Parameter getARequestObjectFromFunctionViews() {
        exists(Function f, AssignStmt asgn, Expr name, Keyword k |
            (name = asgn.getValue().(List).getAnElt().(Call).getPositionalArg(1)
                or name = asgn.getValue().(Tuple).getAnElt().(Call).getPositionalArg(1)
                or ((k = asgn.getValue().(List).getAnElt().(Call).getANamedArg().(Keyword)
                        or k = asgn.getValue().(Tuple).getAnElt().(Call).getANamedArg().(Keyword))
                    and name = k.getValue()
                    and k.getArg() = "view"))
            and asgn.getATarget().toString() = "urlpatterns"
            and f.getName() = name.(Attribute).getName()
            and exists(name.getLocation().getFile().getRelativePath())
            and result = f.getArg(0))
    }

    bindingset[pos]
    Parameter getARequestObjectFromClassViews(int pos) {
        exists(AssignStmt asgn, Expr name, Keyword k, Class cls | 
            (name = asgn.getValue().(List).getAnElt().(Call).getPositionalArg(1)
                or name = asgn.getValue().(Tuple).getAnElt().(Call).getPositionalArg(1)
                or ((k = asgn.getValue().(List).getAnElt().(Call).getANamedArg().(Keyword)
                        or k = asgn.getValue().(Tuple).getAnElt().(Call).getANamedArg().(Keyword))
                    and name = k.getValue()
                    and k.getArg() = "view"))
            and asgn.getATarget().toString() = "urlpatterns"
            and (cls.getName() = name.(Call).getFunc().(Attribute).getObject().(Name).getId()
                or cls.getName() = name.(Call).getFunc().(Attribute).getObject().(Attribute).getName())
            and exists(name.getLocation().getFile().getRelativePath())
            and (result = cls.getAMethod().getArg(pos)
                or result = getARequestObjectFromSuperClassOfClassViews(pos, cls)))
    }

    // TODO have to make this recursive
    Parameter getARequestObjectFromSuperClassOfClassViews(int pos, Class cls) {
        exists(Class supercls | 
            supercls.getName() = cls.getABase().toString()
            and exists(supercls.getLocation().getFile().getRelativePath())
            and result = supercls.getAMethod().getArg(pos))
    }

    Attribute getARequestObjectFromClassViewsUsingSelf() {
        exists(Parameter param, Attribute attr |
            param = getARequestObjectFromClassViews(0)
            and attr.getName() = "request"
            and attr.getObject().getAFlowNode() = param.getVariable().getAUse().getNode().getAFlowNode()
            and result = attr)
    }

    ControlFlowNode getAUserObject() {
        exists(DataFlow::Node src, DataFlow::Node sink, RequestObjectConfiguration config, Attribute atr |
            config.hasFlow(src, sink)
            and atr.getName() = "user"
            and atr.getObject() = sink.asExpr()
            and exists(atr.getLocation().getFile().getRelativePath())
            and result = atr.getAFlowNode())
    }

    ControlFlowNode getUserIsAuthenticatedAccess() {
        exists(Attribute atr |
            atr.getName() = "is_authenticated"
            and atr.getObject().getAFlowNode() = getAUserObject()
            and exists(atr.getLocation().getFile().getRelativePath())
            and result = atr.getAFlowNode())
    }

    ControlFlowNode getUserLastLoginAccess() {
        exists(Attribute atr |
            atr.getName() = "last_login"
            and atr.getObject().getAFlowNode() = getAUserObject()
            and exists(atr.getLocation().getFile().getRelativePath())
            and result = atr.getAFlowNode())
    }

    StrConst getDefaultHashingAlg() {
        exists(DataFlow3::Node source, DataFlow3::Node sink, DataFlow2::Node source2, DataFlow2::Node sink2, PasswordHashersConfiguration config, PasswordHashersListConfiguration config2 |
            config.hasFlow(source, sink)
            and config2.hasFlow(source2, sink2)
            and (source.asExpr().(List).getElt(0) = sink2.asExpr()
                or source.asExpr().(Tuple).getElt(0) = sink2.asExpr())
            and result = sink2.asExpr().(StrConst))
    }

    bindingset[alg]
    StrConst defaultImplOfHashingAlgIsUsed(string alg) {
        exists(StrConst str | 
            str = getDefaultHashingAlg()
            and str.getS() = alg
            and result = str)
    }

    bindingset[alg]
    Class overridenImplOfHashingAlgIsUsed(string alg) {
        exists (Class cls, StrConst str | 
            str = getDefaultHashingAlg()
            and cls.getName() = str.getS().splitAt(".")
            and cls.getABase() = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("hashers").getMember(alg).getAValueReachableFromSource().asExpr() // TODO have to test this
            and (if exists(str.getS().prefix(28))
                then str.getS().prefix(28) != "django.contrib.auth.hashers."
                else any())
            and result = cls)
    }

    bindingset[attrName]
    Expr getAttrValue(Class cls, string attrName) {
        exists(AssignStmt asgn | 
            asgn = cls.getAStmt()
            and asgn.getATarget().(Name).getId() = attrName
            and result = asgn.getValue())
    }

    predicate configSetFromEnvVar(Expr value) {
        exists(DataFlow::Node env | 
            (env = API::moduleImport("os").getMember("getenv").getACall()
                or env = API::moduleImport("os").getMember("environ").getASubscript().getAValueReachableFromSource()
                or env = API::moduleImport("os").getMember("environ").getMember("get").getAValueReachableFromSource())
            and exists(env.getLocation().getFile().getRelativePath())
            and exists(value.getLocation().getFile().getRelativePath())
            and value.getAFlowNode() = env.asCfgNode())
    }

}
