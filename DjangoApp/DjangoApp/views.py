from django.http import HttpResponse
from django.contrib.auth.decorators import login_required
from django.views import View
from django.views.generic import TemplateView
from django.contrib.auth.hashers import make_password
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import login, authenticate
import datetime

@login_required
def current_datetime(request):
    x = 10
    now = datetime.datetime.now()

    # set session cookie expires attribute
    # If value is an integer, the session will expire after that many seconds of inactivity. For example, calling request.session.set_expiry(300) would make the session expire in 5 minutes.
    # If value is a datetime or timedelta object, the session will expire at that specific date/time.
    # If value is 0, the user’s session cookie will expire when the user’s web browser is closed.
    # If value is None, the session reverts to using the global session expiry policy.
    request.session.set_expiry(value=datetime.timedelta(2))
    request.session.set_expiry(x)
    user_check(request)
    pwd = make_password("password", hasher="pbkdf2_sha1")
    validate_password(pwd)
    html = "<html><body>It is now %s.</body></html>" % now
    return HttpResponse(html)

def another_view(rq):
    return HttpResponse("No auth checks")

def user_check(req):
    if req.user.is_authenticated:
        return True
    else:
        return False
    
class ViewClass(View):

    def idk(self, request):
        user_check(request)
        return HttpResponse("Hello world!")
