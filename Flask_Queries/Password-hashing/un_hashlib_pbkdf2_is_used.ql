import python
import semmle.python.ApiGraphs

from API::Node node
where node = API::moduleImport("hashlib").getMember("pbkdf2_hmac")
    and (exists(node.getParameter(1))
        or exists(node.getKeywordParameter("password")))
select node, node.getAValueReachableFromSource().getLocation(), "Hashlib PBKDF2 is being used to hash passwords"
