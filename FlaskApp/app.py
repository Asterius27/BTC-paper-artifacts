from flask import Flask, redirect, url_for, request, session, g
from flask.sessions import SecureCookieSessionInterface
from flask_login import LoginManager, UserMixin, current_user, login_required, login_user, logout_user, fresh_login_required, login_fresh, utils
from typing import Dict, Optional
from datetime import timedelta
import datetime as dt
from config import FlaskConfig, default_config
import os

from flask_bcrypt import Bcrypt, generate_password_hash
from wtforms import Form, PasswordField, ValidationError, BaseForm, EmailField
from wtforms import validators
from wtforms.validators import Length, Regexp, length, DataRequired, Email, EqualTo
from flask_wtf import FlaskForm
from flask_wtf.csrf import CSRFProtect
from passlib.hash import pbkdf2_sha256, argon2, scrypt, bcrypt_sha256, pbkdf2_sha512, sha256_crypt
from passlib.handlers.bcrypt import bcrypt as bcrpt
from argon2 import PasswordHasher, Type
from passlib.context import CryptContext
import hashlib
from hashlib import pbkdf2_hmac
import bcrypt as bcr
from werkzeug.security import generate_password_hash as gen_pass_hash
import passwordmeter
from password_strength import PasswordStats, PasswordPolicy
import deform
from deform import Form as de_form
import colander


def bar():
    return "secret_key"

app = Flask(__name__)
bcrypt = Bcrypt(app)
# csrf = CSRFProtect(app)
csrf = CSRFProtect()
csrf.init_app(app)
key = bar()

# Hardcoded and short secret key
app.config["SECRET_KEY"] = key
app.secret_key = "ciao"

login_manager = LoginManager()
login_manager.init_app(app)

# Session protection with fresh_login_required (in sec() function) (secure implementation)
login_manager.session_protection = "basic"
# login_manager.session_protection = None

# Javascript access to cookies (insecure) (HTTPOnly attribute), default is True
# z = app.config
# z["SESSION_COOKIE_HTTPONLY"] = False
# app.config["REMEMBER_COOKIE_HTTPONLY"] = False
# app.config["SESSION_COOKIE_HTTPONLY"] = False

# Cookies not accessible via HTTP, default is False
# app.config["REMEMBER_COOKIE_SECURE"] = True
# app.config["SESSION_COOKIE_SECURE"] = True

# Cookie shared with subdomains, default is None
# app.config["REMEMBER_COOKIE_DOMAIN"] = ".example.com"
# app.config["SESSION_COOKIE_DOMAIN"] = ".example.com"

# Cookie expiration, can be set using integers (to express seconds), or using the datetime.timedelta object
# app.config["REMEMBER_COOKIE_DURATION"] = 6000 # can also be set as a parameter of the login_user function (duration=...), default is 365 days
# @app.before_request
def make_session_permanent():
    session.permanent = True
# session.permanent = True # default is false
# app.config["PERMANENT_SESSION_LIFETIME"] = timedelta(2) # works only if session.permanent is true, default is 31 days
# or 
# app.permanent_session_lifetime = dt.timedelta(weeks=6, days=2)
# Bump/refresh cookie expiration at each request
# app.config["REMEMBER_COOKIE_REFRESH_EACH_REQUEST"] = True # default is False
app.config["SESSION_REFRESH_EACH_REQUEST"] = False # default is True

# Cookie prefixes
# app.config["REMEMBER_COOKIE_NAME"] = "__Secure-remember" # default is remember_token
# app.config["SESSION_COOKIE_NAME"] = "__Host-session" # default is session

# CSRF (Samesite attribute)
#app.config["REMEMBER_COOKIE_SAMESITE"] = 'Lax' # default is None
# app.config["SESSION_COOKIE_SAMESITE"] = None # default is None

# JSON serializer options, can only use the default json serializer in flask
# Serialize objects to ASCII-encoded JSON. If this is disabled, the JSON will be returned as a Unicode string, or encoded as UTF-8 by jsonify. 
# This has security implications when rendering the JSON into JavaScript in templates, and should typically remain enabled.
# app.config["JSON_AS_ASCII"] = False # default is True

# Another way of setting/updating multiple keys
# app.config.update(SESSION_COOKIE_DOMAIN=".example.com", REMEMBER_COOKIE_SAMESITE="Strict")
# d = {'REMEMBER_COOKIE_SAMESITE': None}
# app.config.update(d)

# Another way of setting/updating multiple keys
class BaseConfigClass(object):
    SECRET_KEY = "somethingsecret"

class ConfigClass(BaseConfigClass):
    a = 10
    # Flask settings
    # SECRET_KEY = 'This is an INSECURE secret!! DO NOT use this in production!!'

def configuration(config_class=FlaskConfig):
    app.config["SESSION_COOKIE_HTTPONLY"] = False
    app.config.from_object(config_class)

# conf = ConfigClass()
# app.config.from_object(__name__+'.ConfigClass') # can also pass an imported module as a parameter
# app.config.from_object(ConfigClass)
# app.config.from_object(ConfigClass())
# app.config.from_object(FlaskConfig)
# app.config.from_object(default_config())
# app.config.from_object(conf)

# Yet another way of setting/updating multiple keys
# app.config.from_pyfile("config.py") # just search if in the file there is, for example, a hardcoded string that gets assigned to a variable named SECRET_KEY

# configuration()

# Set config from environment
# app.config.from_prefixed_env()
# app.config.from_envvar('AN_ENV_VAR')
# app.config["SECRET_KEY"] = os.environ.get("ENVIRON_KEY")
# app.config["SECRET_KEY"] = os.environ["ENVIRON_KEY"]
app.config["SECRET_KEY"] = os.getenv("ENVIRON_KEY")
app.config["SECRET_KEY"] = os.environ.get("ENVIRON_KEY") or "Thisisasecret"
# app.config["SESSION_COOKIE_SAMESITE"] = os.environ.get("ENVIRON_SAMESITE")

app.config["WTF_CSRF_CHECK_DEFAULT"] = False # default is True

# TODO Other ways of setting config (don't think these are very used, just need to check how many repos use these and then decide whether to include them or not)
# app.config.from_mapping()
# app.config.from_file()
# app.config.fromkeys()

# Other password hashing libraries

hash = pbkdf2_sha256.using().hash("password")
testss = sha256_crypt.encrypt("ma dai")
comeon = bcrpt.encrypt("comeon")
pbk = pbkdf2_sha512.using().hash("wow")
alg = argon2.using().hash("bella")
scr = scrypt.using().hash("test")
bcryptt = bcrypt_sha256.using().hash("ciao")
bcrypttr = bcrypt_sha256.using(rounds=15).hash("ciao")
bcryptt2 = bcrypt_sha256.using(rounds=5).hash("ciao")
ctx = CryptContext(schemes=[])
ph = PasswordHasher(type=Type.ID)
hash = ph.hash("correct horse battery staple")
hashed = hashlib.md5("password")
hashed = bcr.hashpw("password", bcr.gensalt())
hash = gen_pass_hash("password", "scrypt:300000:9:1")
hash2 = gen_pass_hash("passwrd", "pbkdf2")
hash3 = gen_pass_hash("omg")

# other password strenght libraries
strength, improvements = passwordmeter.test("password")
policy = PasswordPolicy.from_names(
    length=8,  # min length: 8
    uppercase=2,  # need min. 2 uppercase letters
    numbers=2,  # need min. 2 digits
    special=2,  # need min. 2 special characters
    nonletters=2,  # need min. 2 non-letter characters (digits, specials, anything)
)
res = policy.test("password")
res = policy.password("password").test()
res = policy.password("password").strength()
stats = PasswordStats('G00dPassw0rd?!').strength()
myform = de_form(deform.schema.CSRFSchema, buttons=('submit',))
class ExampleSchema(deform.schema.CSRFSchema):

    name = colander.SchemaNode(
        colander.String(),
        title="Name")

    age = colander.SchemaNode(
        colander.Int(),
        default=18,
        title="Age",
        description="Your age in years")


def aux(a):
    return a

# testing = os.environ.get("ENVIRON_KEY")

# Custom session interface
class CustomSessionInterface(SecureCookieSessionInterface):
    """Prevent creating session from API requests."""
    def save_session(self, *args, **kwargs):
        if g.get('login_via_request'):
            return
        return super(CustomSessionInterface, self).save_session(*args, **kwargs)
    
# app.session_interface = CustomSessionInterface()

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
    """
    @property
    def is_active(self):
        if self.id:
            return False
        return True
    
    @property
    def is_active(self):
        return False
    """
users: Dict[str, "User"] = {
    '1': User(1, 'mario', '1234'),
    '2': User(2, 'paolo', 'password'),
    '3': User(3, 'giovanni', 'abcd')
}

class SuperClass(Form):
    test = 10

class UserRegisterForm(SuperClass): # Form or BaseForm or FlaskForm (from flask_wtf)
    # can also define custom validators and then pass them to the field by adding them to the array. The only way to distinguish them is to check whether they are a wtforms import module or not
    pwd = PasswordField('password', [Length(min=16), Regexp("somepattern"), length(min=18), User(), aux(8)])
    email = EmailField('email', validators=[Length(max=30)])
    test = PasswordField('pwd', validators=[DataRequired()])
    confirm_pwd = PasswordField('conf_pwd')
    # another way to define custom validators
    def validate_pwd(form, field):
        if field.data < 16:
            raise ValidationError("Password is too short")
        
class NoCustomValidatorsRegister(FlaskForm):
    test = PasswordField('pwd', validators=[DataRequired()])
    
    def validate_whatever(form, field):
        raise ValidationError("Test")

class AddUser(BaseForm):
    class Meta:
        csrf = True

    test = PasswordField('pwd')

    def validate_test(form, field):
        raise ValidationError("Test")

class NewUserForm(BaseForm):
    test = PasswordField('pwd', validators=[aux(10)])

class Form_signup(FlaskForm):
    test = PasswordField('pwd')

def helper():
    h = 'max-age=31536000; includeSubDomains' # 1 year
    return h

def set_headers(res, header):
    res.headers['Strict-Transport-Security'] = header

def some_check(next):
    return next == "bella"
"""
@app.after_request
def add_headers(response):
    x = helper()
    y = "useless"
    z = x
    set_headers(response, z)
    return response
"""
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
    # make_session_permanent()
    if user and user.password == password:
        open_redirect_new(user)
        next = open_redirect(request.args.get('next'))

        # Open redirect vulnerability after login
        next = request.args.get('next')
        if next:
            return redirect(next)
        if some_check(next):
            return redirect(next)
        if next == "ciao":
            return redirect(next)
        if not next == "ehi":
            return redirect(url_for("index"))
        
        return redirect(next or url_for("index"))
    return "<h1>Invalid user id or password</h1>"

@csrf.exempt
@app.get("/signup")
def signup():
    form = UserRegisterForm(request.POST)
    # check that form.validate() is called on all forms that have the password field with validators (TODO extra_validators aren't checked for now)
    # TODO can also validate single fields instead of the whole form (not checked for now)
    # if request.POST and form.validate():
        # Default is 12 rounds, shouldn't be lowered, default prefix (algorithm) is 2b, other prefixes should not be used since they are bugged
        # pw_hash = bcrypt.generate_password_hash("password", rounds=10, prefix='2a')
    # When using flask_wtf's FlaskForm you can also call validate_on_submit()
    if request.POST:
        if form.validate_on_submit(): # aux(30)
            hashed_pwd = hashlib.scrypt(form.pwd)
            hashed_passw = pbkdf2_hmac('sha256', form.pwd, b"somesalt", 540000)
            # hashed_pssw = hashlib.scrypt("somepassword", n=131072, r=8, p=1)
            return redirect('/success' + hash3)
    return "Signup"


@app.get("/logout")
@login_required
def logout():
    form = UserRegisterForm(request.POST, None, "", None, {'csrf': True})
    form2 = NoCustomValidatorsRegister(meta={'csrf': False})
    form3 = NewUserForm()
    form4 = Form_signup()
    # session.pop("_permanent")
    # session.clear()
    logout_user()
    return redirect(url_for("index"))

@app.get("/secureroute")
@fresh_login_required
def sec():
    utils.logout_user()
    return "This route requires a fresh login in order to be accessed"

# Cookie attributes have to be set before login occurs, and if they are changed after the login, then if the user logs out and logs in 
# again the new cookies that will be created will have the attributes that were changed earlier after the first login occurred
# So you can't change the current cookie attributes after the login occurred, but those changes will affect the next cookie that will be created by the login.
# So we should check that the config changes are made in the same context of (are reachable from) the flask app initialization (app = Flask(__name__)) 
# (and that there is no login_user() function call between the app = Flask(__name__) and the config change? Probably not necessary TODO)
# Write a general query that just checks if the application does some config changes in places where it shouldn't (or one query for every config change we are interested in? TODO)
@app.get("/cookiesfalse")
def attributest():
    csrf.protect()
    if not current_user.is_authenticated:
        return login_manager.unauthorized()
    app.config["SESSION_COOKIE_HTTPONLY"] = False
    app.config["REMEMBER_COOKIE_HTTPONLY"] = False
    return "<p>Trying to change cookie attributes to false...</p>"

@app.get("/cookiestrue")
def attributesf():
    if not login_fresh():
        return "Login is not fresh"
    app.config["SESSION_COOKIE_HTTPONLY"] = True
    app.config["REMEMBER_COOKIE_HTTPONLY"] = True
    return "<p>Trying to change cookie attributes to true...</p>"

csrf.exempt(attributesf)

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
    login_user(user, remember=True) # duration=dt.timedelta(weeks=10)
    # session["ciao"] = "bella"
