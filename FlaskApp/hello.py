from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    if True:
        pass
    return "<p>Hello, World!</p>"