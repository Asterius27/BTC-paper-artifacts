import python
import semmle.python.dataflow.new.DataFlow

// TODO there might be other ways to set the Secure cookie attribute (not sure because it's a constant, so the only way to set it should be in the settings.py file (which is what this query checks))
// It doesn't have much to do with session management/security, but might be interesting
class SSLRedirectConfiguration extends DataFlow::Configuration {
    SSLRedirectConfiguration() { this = "SSLRedirectConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof ImmutableLiteral
        and source.asExpr().(ImmutableLiteral).booleanValue() = true
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(AssignStmt asgn, Name name | 
            name.getId() = "SECURE_SSL_REDIRECT"
            and asgn.getATarget() = name
            and exists(asgn.getLocation().getFile().getRelativePath())
            and asgn.getValue().getAFlowNode() = sink.asCfgNode()
        )
    }
}

where not exists(DataFlow::Node source, DataFlow::Node sink, SSLRedirectConfiguration config | 
    config.hasFlow(source, sink))
select "All the non-HTTPS requests aren't redirected to HTTPS"
