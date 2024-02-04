import python
import semmle.python.ApiGraphs
import CodeQL_Library.DjangoSession

/*
where not exists(ControlFlowNode node | 
    (node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("decorators").getMember("login_required").getACall().asCfgNode()
    or node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("mixins").getMember("LoginRequiredMixin").getAValueReachableFromSource().asCfgNode()
    or node = DjangoSession::getRequestObject().getMember("current_user").getMember("is_authenticated").getAValueReachableFromSource().asCfgNode())
    and not node.isImportMember())
select "The application never checks whether the user is authenticated or not (no login restricted areas of the app)"
*/

// TODO
from Attribute atr
where atr.getName() = "is_authenticated"
    and exists(atr.getLocation().getFile().getRelativePath())
select atr, atr.getLocation(), atr.getObject().getAFlowNode()
