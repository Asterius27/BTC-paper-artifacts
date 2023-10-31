SECRET_KEY = "supersecretkey"

class FlaskConfig():
    SECRET_KEY = "Idontknowsomethingsecret"

def default_config():
    return FlaskConfig()
