from django.shortcuts import render

import json
from django.http import HttpResponse
from django.utils import timezone
from django.core import serializers
import datetime

from .models import Items

def index(request):
    response_data = { 'now': 32, 'item-list': Items.objects.order_by('post_date')[:10] }
    print(response_data)
    return serializers.serialize('json', Items.objects.all(), fields=('name', 'size'))
    #return HttpResponse(json.dumps(response_data), content_type="application/json")

def detail(request, item_id):
    return HttpResponse("detail on item: {}".format(item_id))

def feed(request):
    #TODO: need to confirm order to display, chrono?, closest? "magic"?
    #TODO: Get items for <USERID>
    response_data = { 'now': timezone.now().__str__(),
                      'item-list': Items.objects.order_by('-post_date')[:10] }
    print(len(response_data['item-list']))
    if len(response_data['item-list'])<1:
        return ""
    return HttpResponse(json.dumps(response_data), content_type="application/json")

def reset(request):
    #TODO: hardcoded values
    item_expire_time=7 #days
    #TODO: Change to POST or DELETE
    Items.objects.all().delete()
    i = Items(
        post_date=timezone.now(),
        expire_date=timezone.now()+datetime.timedelta(days=item_expire_time),
        title="Used lawn mower",
        description="Runs great has 26 inch cut",
        price=50.25,
        method=Items.PICK_UP )
    i.save()
    print("Adding {}".format(i.title))
    return HttpResponse("resetting {}".format(i.title)) #change success value
