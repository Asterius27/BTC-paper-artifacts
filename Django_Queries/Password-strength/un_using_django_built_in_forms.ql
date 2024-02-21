import python
import semmle.python.ApiGraphs

from DataFlow::Node form
where form = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getAValueReachableFromSource()
    and not form.asExpr() instanceof ImportMember
    and exists(form.asCfgNode())
    and exists(form.getLocation().getFile().getRelativePath())
//    or exists(StrConst str | str.getText() = "django.contrib.auth.urls") // doesn't include a url for signup
//    or exists(API::moduleImport("django").getMember("contrib").getMember("auth").getMember("urls"))
select form, form.getLocation(), "Django's built in user creation form is used"
