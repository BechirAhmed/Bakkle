from django.shortcuts import render

from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404

from .models import PushRegistrations

def index(request):
    notification_list = PushRegistrations.objects.order_by('subscribe_date')[:5]
    context = {
        'notification_list': notification_list,
    }
    return render(request, 'notifications/index.html', context)

def register(request, device_token):
    #if request.method == "POST" or request.method == "PUT":
        print("Registering {}".format(device_token))
        print("Registering {}".format(request.POST.device_token))
        n = PushRegistrations()
        n.user_id = 42
        n.device_token = device_token
        n.subscribe_date = timezone.now()
        #HC: expire duration
        import datetime
        n.expire_date = timezone.now() + datetime.timedelta(days=7)
        n.save()
        return HttpResponseRedirect(reverse('notifications:detail', args=(n.id,)))
    #else:
        raise Http404("Wrong method")

def notifyall(request):
    pass

def detail(request, notification_id):
    n = get_object_or_404(PushRegistrations, pk=notification_id)
    return HttpResponse("detail on notification: {}".format(n))
    #return HttpResponse("detail on notification: {}".format(notification_id))
