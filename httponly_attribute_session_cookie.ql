import python

// TODO add dataflow analysis (both inter- and intra-procedural)
from AssignStmt asgn, Name name
where name.getId() = "SESSION_COOKIE_HTTPONLY"
    and asgn.getATarget() = name
    and asgn.getValue().(ImmutableLiteral).booleanValue() = false
    and exists(asgn.getLocation().getFile().getRelativePath())
select asgn.getLocation(), "Session cookie is accessible via javascript (HTTPOnly attribute set to false)"
