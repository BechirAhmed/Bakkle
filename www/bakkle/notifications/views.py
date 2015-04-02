from django.shortcuts import render

import datetime

from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt

from .models import PushRegistrations

def index(request):
    notification_list = PushRegistrations.objects.order_by('subscribe_date')
    context = {
        'notification_list': notification_list,
    }
    return render(request, 'notifications/index.html', context)

@csrf_exempt
#def register(request, device_token):
def register(request):
    #if request.method == "POST" or request.method == "PUT":
        #TODO: these two items are hardcoded
        request.session['user_id'] = 42
        token_expire_time = 7 # days

        device_token = request.POST.get('device_token', "")
        if device_token == None:
            return "" # Need better response

        print("Registering {} to {}".format(device_token, request.session['user_id']))
        n = PushRegistrations.objects.get_or_create(
            device_token=device_token,
            defaults= {'user_id': request.session['user_id'],
                       'subscribe_date': timezone.now(),
                   #    'expire_date': timezone.now() + datetime.timedelta(days=7)
                   })[0]
        n.user_id = request.session['user_id']
        n.device_token = device_token
        n.subscribe_date = timezone.now()
        n.expire_date = timezone.now() + datetime.timedelta(days=token_expire_time)
        n.save()
        return HttpResponseRedirect(reverse('notifications:detail', args=(n.id,)))
    #else:
        raise Http404("Wrong method")

def notifyall(request):
    pass

def detail(request, notification_id):
    n = get_object_or_404(PushRegistrations, pk=notification_id)
    n.send_notification("bob", "default", 42)
    return HttpResponse("detail on notification: {}".format(n))
    #return HttpResponse("detail on notification: {}".format(notification_id))
