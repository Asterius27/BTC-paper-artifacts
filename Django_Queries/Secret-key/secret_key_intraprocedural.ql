import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to change the session engine and set the secret key (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))
string output(StrConst key) {
    // minimum length recommended by the docs is 50
    if key.getS().length() < 50
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

string output2(StrConst key) {
    if key.getS().prefix(16) = "django-insecure-"
    then result = "The secret key was not freshly generated and is insecure (starts with django-insecure-)"
    else result = "The secret key was freshly generated (doesn't starts with django-insecure-)"
}

from DataFlow::ExprNode secsource, DataFlow::ExprNode key
where exists(DataFlow::ExprNode source, DataFlow::ExprNode sink | 
    source.asExpr().(StrConst).getText() = "django.contrib.sessions.backends.signed_cookies"
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SESSION_ENGINE"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue() = sink.asExpr()
    )
    and DataFlow::localFlow(source, sink))
    and secsource.asExpr() instanceof StrConst
    and exists(AssignStmt asgn, Name name | 
        name.getId() = "SECRET_KEY"
        and asgn.getATarget() = name
        and exists(asgn.getLocation().getFile().getRelativePath())
        and asgn.getValue().getAFlowNode() = key.asCfgNode()
    )
    and DataFlow::localFlow(secsource, key)
select key.getLocation(), output(key.asExpr()), output2(key.asExpr())
