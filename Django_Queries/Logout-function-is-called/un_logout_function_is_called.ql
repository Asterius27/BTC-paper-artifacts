import python
import semmle.python.ApiGraphs

where exists(DataFlow::Node login | 
        login = API::moduleImport("django.contrib.auth").getMember("logout").getAValueReachableFromSource()
        and not login.asExpr() instanceof ImportMember
        and exists(login.asCfgNode())
        and exists(login.getLocation().getFile().getRelativePath()))
    or exists(StrConst str | str.getText() = "django.contrib.auth.urls")
    or exists(DataFlow::Node views | 
        views = API::moduleImport("django.contrib.auth").getMember("views").getMember("LogoutView").getAValueReachableFromSource()
        and not views.asExpr() instanceof ImportMember
        and exists(views.asCfgNode())
        and exists(views.getLocation().getFile().getRelativePath()))
select "The logout function is called at least once"
