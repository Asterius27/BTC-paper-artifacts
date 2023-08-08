import python

from If ifstmt, Stmt pass
where pass = ifstmt.getStmt(0) and
  pass instanceof Pass
select ifstmt, "This 'if' statement is redundant...", ifstmt.getLocation()