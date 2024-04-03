import python
import semmle.python.ApiGraphs

from API::Node node
where (node = API::moduleImport("hashlib").getMember("pbkdf2_hmac")
        or node = API::moduleImport("hashlib").getMember("scrypt"))
    and (exists(node.getParameter(0))
        or exists(node.getParameter(1))
        or exists(node.getKeywordParameter("password")))
select node, node.getAValueReachableFromSource().getLocation(), "Hashlib is being used to hash passwords"
