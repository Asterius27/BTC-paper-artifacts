import python
import semmle.python.ApiGraphs

// TODO return true if there are no @fresh_login_required or no flask_login.login_fresh() checks
where not exists(ControlFlowNode node | 
    node = API::moduleImport("flask_login").getMember("fresh_login_required").getACall().asCfgNode()
    or node = API::moduleImport("flask_login").getMember("login_fresh").getACall().asCfgNode())
select "The application never checks whether the current login is fresh or not (no fresh login restricted areas of the app)"
