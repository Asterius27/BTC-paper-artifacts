import python
import semmle.python.ApiGraphs

where not exists(ControlFlowNode node | 
    node = API::moduleImport("flask_login").getMember("login_required").getACall().asCfgNode()
    or (node = API::moduleImport("flask_login").getMember("current_user").getMember("is_authenticated").getAValueReachableFromSource().asCfgNode()
        and not node.isImportMember()))
select "The application never checks whether the user is authenticated or not (no login restricted areas of the app)"
