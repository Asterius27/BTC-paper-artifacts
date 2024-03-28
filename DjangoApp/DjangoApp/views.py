from django.http import HttpResponse
from django.contrib.auth.decorators import login_required
from django.views import View
from django.views.generic import TemplateView
from django.contrib.auth.hashers import make_password
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth import login, authenticate
from django.contrib.auth.urls import urlpatterns
from django.contrib.auth.views import LoginView, logout_then_login
from django.utils.decorators import method_decorator
import datetime
from django.contrib.auth.mixins import LoginRequiredMixin
from django import forms
from django.views.decorators.csrf import requires_csrf_token, ensure_csrf_cookie, csrf_protect, csrf_exempt

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
    user_check3(request)
    pwd = make_password("password", hasher="pbkdf2_sha1")
    validate_password(pwd)
    form = UserCreationForm()
    html = "<html><body>It is now %s.</body></html>" % now
    return HttpResponse(html)

@csrf_exempt
def another_view(rq):
    return HttpResponse("No auth checks")

def user_check(req):
    if req.user.is_authenticated:
        return True
    else:
        return False
    
def user_check2(req):
    if req.user.is_authenticated:
        return True
    else:
        return False
    
def user_check3(req):
    if req.user.is_authenticated:
        return True
    else:
        return False
    
def custom_logout(request):
    response = logout_then_login(request)
    return response
    
class Mixin:
    def dispatch(self, request):
        if not request.user.is_authenticated:
            return "Error!"

@method_decorator(login_required, name='dispatch')
class ViewClass(View, Mixin):

    def idk(self, request):
        user_check(request)
        if self.request.user:
            user_check2(self.request)
            return HttpResponse("User authenticated!")
        return HttpResponse("Hello world!")
    
@method_decorator(csrf_protect)
class ViewClassNoMixin(View):

    def idk(self, request):
        if request.user.is_authenticated:
            return HttpResponse("User authenticated!")
        return HttpResponse("Hello world!")
    
class SignupForm(UserCreationForm):
    password = forms.CharField(widget=forms.PasswordInput())
    class Meta:
        fields = ['username', 'password1', 'password2']
