import python
import semmle.python.ApiGraphs

// TODO return true if there are no @login_required or no current_user.is_authenticated checks
where not exists(ControlFlowNode node | 
    node = API::moduleImport("flask_login").getMember("login_required").getACall().asCfgNode()
    or node = API::moduleImport("flask_login").getMember("current_user").getMember("is_authenticated").getAValueReachableFromSource().asCfgNode())
select "The application never checks whether the user is authenticated or not (no login restricted areas of the app)"
