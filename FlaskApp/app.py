from flask import Flask, redirect, url_for, request, session
from flask_login import LoginManager, UserMixin, current_user, login_required, login_user, logout_user, fresh_login_required
from typing import Dict, Optional
from datetime import timedelta
import datetime as dt
from config import FlaskConfig, default_config

def bar():
    return "secret_key"

def configuration():
    app.config["SESSION_COOKIE_HTTPONLY"] = False

app = Flask(__name__)
key = bar()

# Hardcoded and short secret key
app.config["SECRET_KEY"] = key
# or app.secret_key = "ciao"

login_manager = LoginManager()
login_manager.init_app(app)

# Session protection with fresh_login_required (in sec() function) (secure implementation)
login_manager.session_protection = "basic"

# Javascript access to cookies (insecure) (HTTPOnly attribute), default is True
z = app.config
z["SESSION_COOKIE_HTTPONLY"] = False
app.config["REMEMBER_COOKIE_HTTPONLY"] = False
# app.config["SESSION_COOKIE_HTTPONLY"] = False

# Cookies not accessible via HTTP, default is False
app.config["REMEMBER_COOKIE_SECURE"] = True
# app.config["SESSION_COOKIE_SECURE"] = True

# Cookie shared with subdomains, default is None
# app.config["REMEMBER_COOKIE_DOMAIN"] = ".example.com"
app.config["SESSION_COOKIE_DOMAIN"] = ".example.com"

# Cookie expiration, can be set using integers (to express seconds), or using the datetime.timedelta object
app.config["REMEMBER_COOKIE_DURATION"] = 6000 # can also be set as a parameter of the login_user function (duration=...), default is 365 days
session.permanent = True # default is false
app.config["PERMANENT_SESSION_LIFETIME"] = timedelta(2) # works only if session.permanent is true, default is 31 days
# or 
app.permanent_session_lifetime = dt.timedelta(weeks=6, days=2)

# Cookie prefixes
app.config["REMEMBER_COOKIE_NAME"] = "__Secure-remember" # default is remember_token
app.config["SESSION_COOKIE_NAME"] = "__Host-session" # default is session

# CSRF (Samesite attribute)
app.config["REMEMBER_COOKIE_SAMESITE"] = 'Lax' # default is None
app.config["SESSION_COOKIE_SAMESITE"] = None # default is None

# JSON serializer options, can only use the default json serializer in flask
# Serialize objects to ASCII-encoded JSON. If this is disabled, the JSON will be returned as a Unicode string, or encoded as UTF-8 by jsonify. 
# This has security implications when rendering the JSON into JavaScript in templates, and should typically remain enabled.
app.config["JSON_AS_ASCII"] = False # default is True

# Another way of setting/updating multiple keys
app.config.update(SESSION_COOKIE_DOMAIN=".example.com", REMEMBER_COOKIE_SAMESITE="Strict")
d = {'REMEMBER_COOKIE_SAMESITE': None}
app.config.update(d)

# Another way of setting/updating multiple keys
class BaseConfigClass(object):
    SECRET_KEY = "somethingsecret"

class ConfigClass(BaseConfigClass):
    a = 10
    # Flask settings
    # SECRET_KEY = 'This is an INSECURE secret!! DO NOT use this in production!!'

conf = ConfigClass()
app.config.from_object(__name__+'.ConfigClass') # can also pass an imported module as a parameter
app.config.from_object(ConfigClass)
app.config.from_object(ConfigClass())
app.config.from_object(FlaskConfig) # TODO
app.config.from_object(default_config) # TODO
app.config.from_object(conf)

# Yet another way of setting/updating multiple keys
app.config.from_pyfile("config.py") # just search if in the file there is, for example, a hardcoded string that gets assigned to a variable named SECRET_KEY

configuration()

def aux(a):
    return a

class User(UserMixin):
    def __init__(self, id: str, username: str, password: str):
        self.id = aux(id)
        self.username = username
        self.password = password

    @staticmethod
    def get(user_id: str) -> Optional["User"]:
        return users.get(user_id)

    def __str__(self) -> str:
        return f"<Id: {self.id}, Username: {self.username}>"

    def __repr__(self) -> str:
        return self.__str__()
    
    def get_id(self):
        resu = 8
        x = 5
        return self.id

users: Dict[str, "User"] = {
    '1': User(1, 'mario', '1234'),
    '2': User(2, 'paolo', 'password'),
    '3': User(3, 'giovanni', 'abcd')
}

def helper():
    h = 'max-age=31536000; includeSubDomains' # 1 year
    return h

def set_headers(res, header):
    res.headers['Strict-Transport-Security'] = header

@app.after_request
def add_headers(response):
    x = helper()
    y = "useless"
    z = x
    set_headers(response, z)
    return response

@login_manager.user_loader
def load_user(user_id: str) -> Optional[User]:
    return User.get(user_id)

@app.route("/")
def index():

    # example query
    if True:
        pass

    username = "anonymous"
    if current_user.is_authenticated:
        username = current_user.username
    return f"""
        <h1>Hi {username}</h1>
        <h3>Welcome to Flask Login without ORM!</h3>
        """

@app.get("/login/<id>/<password>")
def login(id, password):
    user = User.get(id)
    if user and user.password == password:
        open_redirect_new(user)
        next = open_redirect(request.args.get('next'))

        # Open redirect vulnerability after login
        next = request.args.get('next')
        if next:
            return redirect(next)
        
        return redirect(url_for("index"))
    return "<h1>Invalid user id or password</h1>"

@app.get("/logout")
@login_required
def logout():
    session.pop("_permanent")
    # session.clear()
    logout_user()
    return redirect(url_for("index"))

@app.get("/secureroute")
@fresh_login_required
def sec():
    return "This route requires a fresh login in order to be accessed"

# Cookie attributes have to be set before login occurs, and if they are changed after the login, then if the user logs out and logs in 
# again the new cookies that will be created will have the attributes that were changed earlier after the first login occurred
# So you can't change the current cookie attributes after the login occurred, but those changes will affect the next cookie that will be created by the login.
# So we should check that the config changes are made in the same context of (are reachable from) the flask app initialization (app = Flask(__name__)) 
# (and that there is no login_user() function call between the app = Flask(__name__) and the config change? Probably not necessary TODO)
# Write a general query that just checks if the application does some config changes in places where it shouldn't (or one query for every config change we are interested in? TODO)
@app.get("/cookiesfalse")
def attributest():
    app.config["SESSION_COOKIE_HTTPONLY"] = False
    app.config["REMEMBER_COOKIE_HTTPONLY"] = False
    return "<p>Trying to change cookie attributes to false...</p>"

@app.get("/cookiestrue")
def attributesf():
    app.config["SESSION_COOKIE_HTTPONLY"] = True
    app.config["REMEMBER_COOKIE_HTTPONLY"] = True
    return "<p>Trying to change cookie attributes to true...</p>"

def open_redirect(url):
    return url

def open_redirect_new(user):
    y = 6
    open_redirect_new_new(user)
    x = 7

def open_redirect_new_new(user):
    if True:
        pass
    else:
        x = 5
    z = 9
    login_user(user, remember=True, duration=dt.timedelta(weeks=10))
