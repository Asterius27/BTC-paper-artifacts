import python
import CodeQL_Library.DjangoSession

from Class cls, ControlFlowNode cfn, Function f
where (cls = DjangoSession::getClassViews()
        and cfn = cls.getEntryNode())
    or (f = DjangoSession::getFunctionViews()
        and cfn = f.getEntryNode())
select cfn, cfn.getLocation()