import python
import semmle.python.ApiGraphs

where not exists(ControlFlowNode node | 
    ((node = API::moduleImport("flask_login").getMember("fresh_login_required").getAValueReachableFromSource().asCfgNode()
        or node = API::moduleImport("flask_login").getMember("utils").getMember("fresh_login_required").getAValueReachableFromSource().asCfgNode())
        and not node.isImportMember())
    or node = API::moduleImport("flask_login").getMember("login_fresh").getACall().asCfgNode()
    or node = API::moduleImport("flask_login").getMember("utils").getMember("login_fresh").getACall().asCfgNode())
select "The application never checks whether the current login is fresh or not (no fresh login restricted areas of the app)"
