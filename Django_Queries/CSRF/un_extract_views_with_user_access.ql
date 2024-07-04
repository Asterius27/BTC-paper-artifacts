import python
import CodeQL_Library.DjangoSession

from Class cls, ControlFlowNode cfn, Function f
where (cls = DjangoSession::getClassViews()
        and DjangoSession::exemptClassAccessesUserObject(cls)
        and cfn = cls.getEntryNode())
    or (f = DjangoSession::getFunctionViews()
        and DjangoSession::exemptFunctionAccessesUserObject(f)
        and cfn = f.getEntryNode())
select cfn, cfn.getLocation()