import python
import CodeQL_Library.FlaskLogin

from Class cls, ControlFlowNode cfn, Function f, ControlFlowNode user
where (user = API::moduleImport("flask_login").getMember("current_user").getAValueReachableFromSource().asCfgNode()
        or user = API::moduleImport("flask_login").getMember("utils").getMember("current_user").getAValueReachableFromSource().asCfgNode())
    and ((cls = FlaskLogin::getClassViews()
            and cls.getAMethod().getBody().contains(user.getNode())
            and cfn = cls.getEntryNode())
        or (f = FlaskLogin::getFunctionViews()
            and f.getBody().contains(user.getNode())
            and cfn = f.getEntryNode()))
select cfn, cfn.getLocation()
