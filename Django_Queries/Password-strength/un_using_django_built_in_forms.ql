import python
import semmle.python.ApiGraphs

where exists(DataFlow::Node form |
    form = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getAValueReachableFromSource()
    and not form.asExpr() instanceof ImportMember
    and exists(form.asCfgNode())
    and exists(form.getLocation().getFile().getRelativePath()))
    or exists(StrConst str | str.getText() = "django.contrib.auth.urls")
    or exists(API::moduleImport("django").getMember("contrib").getMember("auth").getMember("urls"))
select "Django's built in user creation form is used"
