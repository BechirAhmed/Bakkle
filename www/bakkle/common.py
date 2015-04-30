from django.shortcuts import render

import json

from django.http import HttpResponse, HttpResponseRedirect, Http404, HttpResponseForbidden
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from account.models import Account, Device

# Decorator for login authentication
def authenticate(function):
    def wrap(request, *args, **kwargs):
        auth_token = request.POST.get('auth_token', "")
        device_uuid = request.POST.get('device_uuid', "")

        # check if any of the required fields are empty
        if auth_token == None or auth_token.strip() == "" or auth_token.find('_') == -1 or device_uuid == None or device_uuid.strip() == "":
            response_data = { "status":0, "error":"Required parameters missing! Need auth_token and device_uuid. A: {} D: {}".format(auth_token, device_uuid) }
            return HttpResponse(json.dumps(response_data), content_type="application/json")
        
        # get the account id and the device the user is logging in from
        account_id = auth_token.split('_')[1]
        device = get_object_or_404(Device, account_id = account_id, uuid = device_uuid)

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
