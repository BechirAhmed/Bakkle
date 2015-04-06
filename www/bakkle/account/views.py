from django.shortcuts import render

import datetime

from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt

from .models import Account, Device

# Show a list of all accounts in the system.
def index(request):
    account_list = Account.objects.all()
    context = {
        'account_list': account_list,
    }
    return render(request, 'account/index.html', context)

@csrf_exempt
def facebook(request):
    if request.method == "POST" or request.method == "PUT":
        #TODO: these two items are hardcoded
        request.session['user_id'] = 42  # FROM DB.
        token_expire_time = 7 # days

        facebook_id = request.POST.get('id', "")
        if device_token == None:
            return "" # Need better response

        #print("Registering user based on Facebook auth {} to {}".format(device_token, request.session['user_id']))
        n = Account.objects.get_or_create(
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
        return HttpResponseRedirect(reverse('account:detail', args=(n.id,)))
    else:
        raise Http404("Wrong method")

# Show detail on an account
def detail(request, account_id):
    account = get_object_or_404(Account, pk=account_id)
    devices = Device.objects.filter(account_id=account_id)
    context = {
        'account': account,
        'devices': devices,
    }
    return render(request, 'account/detail.html', context)



## DEVICE STUFF

# Show detail on a device
def device_detail(request, device_id):
    device = get_object_or_404(Device, pk=device_id)
    context = {
        'device': device,
    }
    return render(request, 'account/device_detail.html', context)

# Register a new device for notifications
@csrf_exempt
def device_register(request):
    if request.method == "POST" or request.method == "PUT":
        #TODO: these two items are hardcoded
        request.session['user_id'] = 42
        token_expire_time = 7 # days

        device_token = request.POST.get('device_token', "")
        if device_token == None:
            return "" # Need better response

        print("Registering {} to {}".format(device_token, request.session['user_id']))
        n = Device.objects.get_or_create(
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
    else:
        raise Http404("Wrong method")

# Dispatch a notification to device
def device_notify(request, device_id):
    n = get_object_or_404(Device, pk=device_id)
    n.send_notification("bob", "default", 42)
    return HttpResponse("detail on notification: {}".format(n))

