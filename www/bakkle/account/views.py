from django.shortcuts import render

import datetime
import json

from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt

from .models import Account, Device
from items.models import Items, BuyerItem

# Show a list of all accounts in the system.
@csrf_exempt
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
        token_expire_time = 7  # days

        facebook_id = request.POST.get('UserID', "")
        display_name = request.POST.get('Name',"")
        email = request.POST.get('email', "")
        uuid = request.POST.get('device_uuid', "")
        if (facebook_id == None or facebook_id == "") or (uuid == None or uuid == "") or (email == None or email == ""):
            return "" # TODO: Need better response

        if display_name == None or display_name == "":
            first_name = request.POST.get('FirstName', "")
            last_name = request.POST.get('LastName', "")
            if (first_name == None or first_name == "") or (last_name == None or last_name == ""):
                return "" # TODO: Add Better Response
            else:
                display_name = first_name + " " + last_name

        account = Account.objects.get_or_create(
            facebook_id=facebook_id,
            defaults= {'display_name': display_name,
                       'email': email,
                   })[0]
        account.display_name = display_name
        account.email = email
        account.save()

        device_register(get_client_ip(request), uuid, account)
        response_data = {'status':1, 'account_id':account.id}
        return HttpResponse(json.dumps(response_data), content_type="application/json")
    else:
        raise Http404("Wrong method, use POST")

# Show detail on an account
@csrf_exempt
def detail(request, account_id):
    account = get_object_or_404(Account, pk=account_id)
    devices = Device.objects.filter(account_id=account_id)
    buyer_items = BuyerItem.objects.filter(buyer=account_id)
    context = {
        'account': account,
        'devices': devices,
        'items': buyer_items,
    }
    print(context)
    return render(request, 'account/detail.html', context)

## DEVICE STUFF

# Show detail on a device
@csrf_exempt
def device_detail(request, device_id):
    device = get_object_or_404(Device, pk=device_id)
    context = {
        'device': device,
    }
    return render(request, 'account/device_detail.html', context)

# Register a new device
def device_register(ip, uuid, user):
    device = Device.objects.get_or_create(
        uuid = uuid,
        account_id= user,
        defaults={'notifications_enabled': True, })[0]
    device.last_seen_date = datetime.datetime.now()
    device.ip_address = ip
    device.save()

# Register a new device for notifications
@csrf_exempt
def device_register_push(request):
    if request.method == "POST" or request.method == "PUT":

        device_token = request.POST.get('device_token', "")
        account_id = request.POST.get('account_id', "")
        uuid = request.POST.get('device_uuid', "")
        if (device_token == None or device_token == "") or (account_id == None or account_id == "") or (uuid == None or uuid == ""):
            return "" # Need better response

        print("Registering {} to {}".format(device_token, account_id))
        account = get_object_or_404(Account, pk=account_id)
        device = Device.objects.get_or_create(
            uuid = uuid,
            account_id = account,
            defaults={'notifications_enabled': True, })[0]
        device.last_seen_date = datetime.datetime.now()
        device.ip_address = get_client_ip(request)
        device.apns_token = device_token
        device.save()
        return HttpResponseRedirect(reverse('account:device_detail', args=(device.id,)))
    else:
        raise Http404("Wrong method")

# Dispatch a notification to device
@csrf_exempt
def device_notify(request, device_id):
    n = get_object_or_404(Device, pk=device_id)
    n.send_notification("bob", "default", 42)
    return HttpResponse("detail on notification: {}".format(n))

def get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip
