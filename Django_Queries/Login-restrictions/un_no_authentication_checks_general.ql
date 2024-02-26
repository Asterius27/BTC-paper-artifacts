import python
import semmle.python.ApiGraphs
import CodeQL_Library.DjangoSession

where not exists(ControlFlowNode node | 
    (node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("decorators").getMember("login_required").getAValueReachableFromSource().asCfgNode()
    or node = API::moduleImport("django").getMember("contrib").getMember("auth").getMember("mixins").getMember("LoginRequiredMixin").getAValueReachableFromSource().asCfgNode()
    or node = DjangoSession::getAUserObject())
    and not node.isImportMember())
select "The application never accesses the user object and never uses the @login_required decorator and never uses the LoginRequiredMixin (for class based views)"
