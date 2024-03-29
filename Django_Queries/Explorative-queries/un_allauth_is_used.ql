import python
import semmle.python.ApiGraphs

// This library has login/logout ecc. built in
from StrConst str
where str.getText() = "allauth"
    or str.getText().prefix(8) = "allauth."
select "Django-allauth is being used by the application"
