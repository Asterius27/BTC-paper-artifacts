import python
import semmle.python.ApiGraphs
import semmle.python.frameworks.Flask

// approximately 1 byte per char and recommended length for SHA1 is 24 bytes
string output(Expr node, Expr value) {
  if node instanceof StrConst
  then if node.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
  else if value.(StrConst).getS().length() < 24
    then result = "The secret key is a hardcoded string and it's too short"
    else result = "The secret key is a hardcoded string"
}

Expr aux() {
    exists(DataFlow::ExprNode source, DataFlow::Node sink |
        (sink = Flask::FlaskApp::instance().getMember("config").getSubscript("SECRET_KEY").asSink()
        or sink = Flask::FlaskApp::instance().getMember("secret_key").asSink()
        or sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getKeywordParameter("SECRET_KEY").asSink())
        and source.asExpr() instanceof StrConst
        and DataFlow::localFlow(source, sink)
        and result = source.asExpr())
}

Expr auxd() {
    exists(DataFlow::Node sink, DataFlow::ExprNode dsource, KeyValuePair kv | 
        sink = Flask::FlaskApp::instance().getMember("config").getMember("update").getParameter(0).asSink()
        and kv = dsource.asExpr().(Dict).getAnItem()
        and kv.getKey().(Str).getText() = "SECRET_KEY"
        and kv.getValue() instanceof StrConst
        and DataFlow::localFlow(dsource, sink)
        and result = kv.getValue())
}

select output(aux(), auxd())
