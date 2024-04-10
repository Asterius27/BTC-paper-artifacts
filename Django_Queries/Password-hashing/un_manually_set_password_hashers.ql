import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to set the password hashers (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))
class PasswordHashersConfiguration extends DataFlow::Configuration {
    PasswordHashersConfiguration() { this = "PasswordHashersConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, AugAssign augasgn, Name name | 
            name.getId() = "PASSWORD_HASHERS"
            and ((asgn.getATarget() = name
                and exists(asgn.getLocation().getFile().getRelativePath())
                and asgn.getValue().getAFlowNode() = sink.asCfgNode())
            or (augasgn.getTarget() = name
                and exists(augasgn.getLocation().getFile().getRelativePath())
                and augasgn.getValue().getAFlowNode() = sink.asCfgNode()))
        )
    }
}

from DataFlow::Node source, DataFlow::Node sink, PasswordHashersConfiguration config
where config.hasFlow(source, sink)
select source, sink, source.getLocation(), sink.getLocation(), "Not using the default password hashers configuration"
