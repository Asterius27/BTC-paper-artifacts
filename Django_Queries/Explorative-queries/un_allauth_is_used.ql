import python
import semmle.python.ApiGraphs

// TODO
from StrConst str
where str.getText() = "allauth"
select "Django-allauth is being used by the application"
