import python
import semmle.python.ApiGraphs

from StrConst str
where str.getText() = "allauth"
select "Django-allauth is being used by the application"
