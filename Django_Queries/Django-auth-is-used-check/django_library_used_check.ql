import python
import semmle.python.ApiGraphs

where exists(DataFlow::Node auth, DataFlow::Node login | 
        auth = API::moduleImport("django.contrib.auth").getMember("authenticate").getAValueReachableFromSource()
        and not auth.asExpr() instanceof ImportMember
        and exists(auth.asCfgNode())
        and exists(auth.getLocation().getFile().getRelativePath())
        and login = API::moduleImport("django.contrib.auth").getMember("login").getAValueReachableFromSource()
        and not login.asExpr() instanceof ImportMember
        and exists(login.asCfgNode())
        and exists(login.getLocation().getFile().getRelativePath()))
    or exists(StrConst str | str.getText() = "django.contrib.auth.urls")
    or exists(DataFlow::Node views | 
        views = API::moduleImport("django.contrib.auth").getMember("views").getMember("LoginView").getAValueReachableFromSource()
        and not views.asExpr() instanceof ImportMember
        and exists(views.asCfgNode())
        and exists(views.getLocation().getFile().getRelativePath()))
    or exists(DataFlow::Node form |
        form = API::moduleImport("django.contrib.auth.forms").getMember("AuthenticationForm").getAValueReachableFromSource()
        and not form.asExpr() instanceof ImportMember
        and exists(form.asCfgNode())
        and exists(form.getLocation().getFile().getRelativePath()))
select "Django authentication is actually used"
