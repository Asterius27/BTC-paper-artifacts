from flask import Flask, redirect, url_for, request, session
from flask_login import LoginManager, UserMixin, current_user, login_required, login_user, logout_user, fresh_login_required
from typing import Dict, Optional
from datetime import timedelta
import datetime as dt

def bar():
    return "secret_key"

app = Flask(__name__)
key = bar()

# Hardcoded and short secret key
app.config["SECRET_KEY"] = key
# or app.secret_key = "ciao"

login_manager = LoginManager()
login_manager.init_app(app)

# Session protection with fresh_login_required (in sec() function) (secure implementation)
login_manager.session_protection = "basic"

# Javascript access to cookies (insecure)
z = app.config
z["SESSION_COOKIE_HTTPONLY"] = False
app.config["REMEMBER_COOKIE_HTTPONLY"] = False
# app.config["SESSION_COOKIE_HTTPONLY"] = False

# Cookies not accessible via HTTP, default is False
app.config["REMEMBER_COOKIE_SECURE"] = True
# app.config["SESSION_COOKIE_SECURE"] = True

# Cookie shared with subdomains
# app.config["REMEMBER_COOKIE_DOMAIN"] = False # valid for all subdomains of SERVER_NAME, default is None
app.config["SESSION_COOKIE_DOMAIN"] = ".example.com"

# Cookie expiration, can be set using integers (to express seconds), or using the datetime.timedelta object
app.config["REMEMBER_COOKIE_DURATION"] = 6000 # can also be set as a parameter of the login_user function (duration=...), default is 365 days
session.permanent = True
app.config["PERMANENT_SESSION_LIFETIME"] = timedelta(days=3) # works only if session.permanent is true, default is 31 days
# or app.permanent_session_lifetime = dt.timedelta(weeks=6, days=2)

# Cookie prefixes
app.config["REMEMBER_COOKIE_NAME"] = "__Secure-remember" # default is remember_token
app.config["SESSION_COOKIE_NAME"] = "__Host-session" # default is session

class User(UserMixin):
    def __init__(self, id: str, username: str, password: str):
        self.id = id
        self.username = username
        self.password = password

    @staticmethod
    def get(user_id: str) -> Optional["User"]:
        return users.get(user_id)

    def __str__(self) -> str:
        return f"<Id: {self.id}, Username: {self.username}>"

    def __repr__(self) -> str:
        return self.__str__()

users: Dict[str, "User"] = {
    '1': User(1, 'mario', '1234'),
    '2': User(2, 'paolo', 'password'),
    '3': User(3, 'giovanni', 'abcd')
}

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
    logout_user()
    return redirect(url_for("index"))

@app.get("/secureroute")
@fresh_login_required
def sec():
    return "This route requires a fresh login in order to be accessed"

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
    login_user(user, remember=True)
