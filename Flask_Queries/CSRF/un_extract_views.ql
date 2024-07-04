import python
import CodeQL_Library.FlaskLogin

from Class cls, ControlFlowNode cfn, Function f
where (cls = FlaskLogin::getClassViews()
        and cfn = cls.getEntryNode())
    or (f = FlaskLogin::getFunctionViews()
        and cfn = f.getEntryNode())
select cfn, cfn.getLocation()
