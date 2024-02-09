import python
import semmle.python.ApiGraphs

from DataFlow::Node form
where form = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("forms").getMember("UserCreationForm").getAValueReachableFromSource()
    and not form.asExpr() instanceof ImportMember
    and exists(form.asCfgNode())
    and exists(form.getLocation().getFile().getRelativePath())
select form, form.getLocation(), "Django's built in user creation form is used"
