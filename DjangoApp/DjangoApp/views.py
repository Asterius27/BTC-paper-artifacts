from django.http import HttpResponse
import datetime

def current_datetime(request):
    now = datetime.datetime.now()
    request.session.set_expiry(0)
    html = "<html><body>It is now %s.</body></html>" % now
    return HttpResponse(html)
