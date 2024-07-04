import python
import CodeQL_Library.FlaskLogin
import semmle.python.dataflow.new.DataFlow4

Class classViewContainsNode(ControlFlowNode node) {
    exists(Class cls |
        cls = FlaskLogin::getClassViews()
        and cls.getAMethod().getBody().contains(node.getNode())
        and result = cls)
}

Function functionViewContainsNode(ControlFlowNode node) {
    exists(Function f |
        f = FlaskLogin::getFunctionViews()
        and f.getBody().contains(node.getNode())
        and result = f)
}

from DataFlow::Node commit, ControlFlowNode cfn, API::Node mid
where(commit = API::moduleImport("sqlalchemy").getMember("orm").getMember("sessionmaker").getReturn().getReturn().getMember("commit").getAValueReachableFromSource()
        or commit = API::moduleImport("sqlalchemy").getMember("orm").getMember("create_session").getReturn().getMember("commit").getAValueReachableFromSource()
        or ((mid = API::moduleImport("sqlalchemy").getMember("orm").getMember("scoped_session")
                or mid = API::moduleImport("sqlalchemy").getMember("orm").getMember("contextual_session"))
            and mid.getParameter(0).getAValueReachingSink().asCfgNode() = API::moduleImport("sqlalchemy").getMember("orm").getMember("sessionmaker").getACall().asCfgNode()
            and commit = mid.getReturn().getReturn().getMember("commit").getAValueReachableFromSource())
        or commit = API::moduleImport("flask_sqlalchemy").getMember("SQLAlchemy").getReturn().getAMember().getMember("commit").getAValueReachableFromSource())
    and (cfn = classViewContainsNode(commit.asCfgNode()).getEntryNode()
        or cfn = functionViewContainsNode(commit.asCfgNode()).getEntryNode())
select cfn, cfn.getLocation(), "This view writes data in the database"
