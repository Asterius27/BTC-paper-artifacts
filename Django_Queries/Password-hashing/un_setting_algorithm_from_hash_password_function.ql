import python
import semmle.python.ApiGraphs

from DataFlow::Node node
where (node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("hashers").getMember("make_password").getKeywordParameter("hasher").getAValueReachingSink()
        or node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("hashers").getMember("make_password").getParameter(2).getAValueReachingSink())
    and exists(node.getLocation().getFile().getRelativePath())
select node, node.getLocation(), "Setting the password hashing algorithm from the make_password function, without using PASSWORD_HASHERS in settings.py"
