import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("password_validation").getMember("validate_password").getParameter(2).getAValueReachingSink()
        or node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("password_validation").getMember("validate_password").getKeywordParameter("password_validators").getAValueReachingSink())
    and exists(node.getLocation().getFile().getRelativePath())
select node.getLocation(), "Using custom validators in a custom form, through django's functions"
