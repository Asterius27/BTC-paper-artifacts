from flask import Flask
from flask_login import LoginManager

app = Flask(__name__)
login_manager = LoginManager()
login_manager.init_app(app)

@app.route("/")
def hello_world():
    if True:
        pass
    return "<p>Hello, World!</p>"