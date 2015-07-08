from django.shortcuts import render

import json
import time
import threading

from django.http import HttpResponse, HttpResponseRedirect, Http404, HttpResponseForbidden
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.db.models import Q

# from items.models import Items
from timing.models import Timing

# Decorator for login authentication
def authenticate(function):

    from account.models import Account, Device

    def wrap(request, *args, **kwargs):
        auth_token = request.POST.get('auth_token', request.GET.get('auth_token', ""))
        device_uuid = request.POST.get('device_uuid', request.GET.get('device_uuid', ""))        

        # check if any of the required fields are empty
        if auth_token == None or auth_token.strip() == "" or auth_token.find('_') == -1 or device_uuid == None or device_uuid.strip() == "":
            response_data = { "status":0, "error":"Required parameters missing! Need auth_token and device_uuid. A: {} D: {}".format(auth_token, device_uuid) }
            return HttpResponse(json.dumps(response_data), content_type="application/json")
        
        # get the account id and the device the user is logging in from
        account_id = auth_token.split('_')[1]
        try:
            device = Device.objects.get(account_id = account_id, uuid = device_uuid)
        except Device.DoesNotExist:
            device = None
            response_data = {"status":0, "error":"Device {} does not exist for account {}.".format(device_uuid, account_id)}
            return HttpResponse(json.dumps(response_data), content_type="application/json")

        # check if the device has a token first (first time logging in)
        if device.auth_token == "":
            response_data = { "status":0, "error":"No authentication token for this device! Need to log in from this device." }
            return HttpResponse(json.dumps(response_data), content_type="application/json")

        # check if the tokens match
        if device.auth_token == auth_token:
            return function(request, *args, **kwargs)
        else:
            response_data = { "status":0, "error":"Authentication token does not match the device and account." }
            return HttpResponse(json.dumps(response_data), content_type="application/json")
    wrap.__doc__ = function.__doc__
    wrap.__name__=function.__name__
    return wrap


# Decorator for login authentication
def time_method(function):
    def wrap(*args, **kwargs):
        time1 = time.time()
        ret = function(*args, **kwargs)
        time2 = time.time()

        user = 0
        try:
            user = request.POST.get('auth_token').split('_')[1]
        except:
            pass

        Timing.objects.create(user = user, func = function.func_name, time = int((time2-time1)*1000.0), args = args)
        print '%s function took %0.3f ms' % (function.func_name, (time2-time1)*1000.0)
        return ret
    return wrap

# Decorator for login authentication
def run_async(function):
    def wrap(*args, **kwargs):

        print("Running function " + str(function.func_name) + " in separate thread");
        function_t = threading.Thread(target=time_method(function), args=args, kwargs = kwargs);
        function_t.start()

    return wrap

# Decorator for login authentication
def run_future(function):
    def wrap(*args, **kwargs):

        print("Running function " + str(function.func_name) + " in separate thread");
        function_t = threading.Thread(target=time_method(function), args=args, kwargs = kwargs);
        function_t.start()

    return wrap


# def get_number_conversations_with_new_messages(account_id):

#     items_selling = Items.objects.filter(seller=account_id).exclude(status = Items.DELETED)
#     convos = Conversation.objects.filter(Q(buyer=account_id,deleted_buyer = False) | Q(item__in=items_selling, deleted_seller=False))
    
#     convos_with_new_message = 0
#     for convo in convos:
#         buyer_id = convo.buyer.id
#         buyer_flag = False
#         if str(account_id) == str(buyer_id):
#             buyer_flag = True

#         messages = 0
#         if(buyer_flag):
#             messages = Message.objects.filter(viewed=None, buyer_seller_flag=False, conversation=convo).count()
#         else:
#            messages = Message.objects.filter(viewed=None, buyer_seller_flag=True, conversation=convo).count()
         

#         if messages > 0:
#             convos_with_new_message = convos_with_new_message + 1
#     return convos_with_new_message