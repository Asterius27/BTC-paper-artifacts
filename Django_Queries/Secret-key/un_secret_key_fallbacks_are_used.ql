import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to set the secret key fallbacks (not sure because they are constants, so the only way to set them should be in the settings.py file (which is what this query checks))
class SecretKeyConfiguration extends DataFlow::Configuration {
    SecretKeyConfiguration() { this = "SecretKeyConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        exists(source.getLocation().getFile().getRelativePath())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SECRET_KEY_FALLBACKS"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

from DataFlow::Node secsource, DataFlow::Node key, SecretKeyConfiguration sconfig
where sconfig.hasFlow(secsource, key)
select key.getLocation(), "Secret key fallbacks are being used"
