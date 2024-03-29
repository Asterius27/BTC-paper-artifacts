import python
import semmle.python.ApiGraphs

// This library has login/logout ecc. built in
from StrConst str
where str.getText() = "dj_rest_auth"
select "Django-allauth is being used by the application"
