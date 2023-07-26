from flask import Flask, redirect, url_for, request
from flask_login import LoginManager, UserMixin, current_user, login_required, login_user, logout_user
from typing import Dict, Optional

app = Flask(__name__)
app.secret_key = "your_secret_key"
login_manager = LoginManager()
login_manager.init_app(app)

# Javascript access to cookies (insecure)
app.config["REMEMBER_COOKIE_HTTPONLY"] = False
app.config["SESSION_COOKIE_HTTPONLY"] = False

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
        next = open_redirect(request.args.get('next'), user)
        

        # Open redirect vulnerability
        # next = request.args.get('next')
        if next:
            return redirect(next)
        
        return redirect(url_for("index"))
    return "<h1>Invalid user id or password</h1>"

@app.get("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for("index"))

def open_redirect(url, user):
    login_user(user, remember=True)
    return url
