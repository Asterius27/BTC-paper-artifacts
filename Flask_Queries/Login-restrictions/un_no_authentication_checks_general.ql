import python
import semmle.python.ApiGraphs

where not exists(ControlFlowNode node | 
    (node = API::moduleImport("flask_login").getMember("login_required").getAValueReachableFromSource().asCfgNode()
        or node = API::moduleImport("flask_login").getMember("current_user").getAValueReachableFromSource().asCfgNode())
    and not node.isImportMember())
select "The application never accesses the current_user object and never uses the @login_required decorator"
