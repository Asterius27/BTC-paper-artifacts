from django.http import HttpResponse
import datetime

def current_datetime(request):
    now = datetime.datetime.now()

    # set session cookie expires attribute
    # If value is an integer, the session will expire after that many seconds of inactivity. For example, calling request.session.set_expiry(300) would make the session expire in 5 minutes.
    # If value is a datetime or timedelta object, the session will expire at that specific date/time.
    # If value is 0, the user’s session cookie will expire when the user’s web browser is closed.
    # If value is None, the session reverts to using the global session expiry policy.
    request.session.set_expiry(10)
    
    html = "<html><body>It is now %s.</body></html>" % now
    return HttpResponse(html)
