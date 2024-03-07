import python
import semmle.python.ApiGraphs

from DataFlow::Node form
where form = API::moduleImport("django").getMember("forms").getMember("PasswordInput").getAValueReachableFromSource()
    and not form.asExpr() instanceof ImportMember
    and exists(form.asCfgNode())
    and exists(form.getLocation().getFile().getRelativePath())
select form, form.getLocation(), "Django's built in password fields are being used for some forms"
