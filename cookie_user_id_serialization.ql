import python
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs
import semmle.python.Concepts
import semmle.python.objects.ObjectInternal

// TODO finish this
/*
class CookieConfiguration extends DataFlow::Configuration {
    CookieConfiguration() { this = "CookieConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source instanceof RemoteFlowSource
    }

    override predicate isSink(DataFlow::Node sink) {
        sink = Flask::FlaskApp::instance().getMember("session").getSubscript("_user_id")
    }
}

from RemoteFlowSource source
select source, source.getLocation(), source.asCfgNode(), source.getSourceType()
*/

// select API::moduleImport("flask").getMember("session").getSubscript("_user_id").getAValueReachingSink().getLocation()

/*
from Encoding source
select source, source.getLocation(), source.asCfgNode(), source.getAnInput()
*/

// maybe somthing like a dataflow analysis from a remoteflowsource into the id field of any object of type User (or in general any class that extends UserMixin)
// then extend to any object that is passed to the login_user function (check that the object's get_id function returns something that is not constant nor user controlled data)

/*
class CookieConfiguration extends DataFlow::Configuration {
    CookieConfiguration() { this = "CookieConfiguration" }

    override predicate isSource(DataFlow::Node source) {
        source instanceof RemoteFlowSource
    }

    override predicate isSink(DataFlow::Node sink) {
        exists(Attribute a | 
            a.getAttr() = "id"
            and a.getObject())
    }
}

from DataFlow::Node source, DataFlow::Node sink, CookieConfiguration config
where config.hasFlow(source, sink)
select source, sink
*/

/*
from Attribute a, ClassObject cls, ObjectInternal o
where o.getClass().getName() = cls.getName()
    and cls.getASuperType().getName() = "UserMixin"
    // and a.getAttr() = "id"
    // and a.getLocation().toString() = o.getOrigin().getLocation().toString()
    // and cls.hasAttribute("id")
select o
*/

from ClassValue cls, ControlFlowNode node, AttrNode attr, ClassValue originCls
where cls.getASuperType().getName() = "UserMixin" 
    and node.pointsTo().getClass() = cls
    and attr.getName() = "id"
    and attr.getObject() = node
    // and attr.getObject(name) = node
    // and val = cls.lookup(name)
    // and originCls.declaredAttribute(name) = val
select cls, attr, attr.getLocation()

/*
from Attribute a
where a.getAttr() = "id"
select a.getLocation()
*/
