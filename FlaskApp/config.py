SECRET_KEY = "supersecretkey"

class FlaskConfig():
    SECRET_KEY = "Idontknowsomethingsecret"

def default_config():
    b = 10
    test = FlaskConfig()
    z = "ciao"
    return test
