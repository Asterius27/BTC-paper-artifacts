import python
import semmle.python.ApiGraphs

// TODO fix moduleImport("flask_login").getMember("utils")
where not exists(DataFlow::Node force | 
    force = API::moduleImport("flask_login").getMember("login_user").getKeywordParameter("force").getAValueReachingSink()
    or force = API::moduleImport("flask_login").getMember("login_user").getParameter(3).getAValueReachingSink())
select "force parameter is left as default, which is false"