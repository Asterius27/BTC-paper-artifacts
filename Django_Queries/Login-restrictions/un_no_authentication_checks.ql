import python
import semmle.python.ApiGraphs
import CodeQL_Library.DjangoSession

where not exists(ControlFlowNode node | 
    (node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("decorators").getMember("login_required").getAValueReachableFromSource().asCfgNode()
    or node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("mixins").getMember("LoginRequiredMixin").getAValueReachableFromSource().asCfgNode()
    or node = DjangoSession::getUserIsAuthenticatedAccess())
    and not node.isImportMember())
select "The application never checks whether the user is authenticated or not (no login restricted areas of the app)"
