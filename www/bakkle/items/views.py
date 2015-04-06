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
        imageUrls = "https://app.bakkle.com/images/b8347df.jpg",
        title = "Orange Push Mower",
        description = "Year old orange push mower. Some wear and sun fadding. Was kept outside and not stored in shed.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 50.25,
        tags = "lawnmower, orange, somewear",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        postDate = datetime.datetime.now,
        timesReported = 0 )
    i.save()
    i = Items(
        imageUrls = "https://app.bakkle.com/images/b8348df.jpg",
        title = "Rabbit Push Mower",
        description = "Homemade lawn mower. Includes rabbit and water container.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 10.99,
        tags = "lawnmower, homemade, rabbit",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        postDate = datetime.datetime.now,
        timesReported = 0 )
    i = Items(
        imageUrls = "https://app.bakkle.com/images/b8349df.jpg,https://app.bakkle.com/images/b8350df.jpg",
        title = "iPhone 6 Cracked",
        description = "iPhone 6. Has a cracked screen. Besides screen phone is in good condition.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 65.99,
        tags = "iPhone6, cracked, damaged",
        method = Items.DELIVERY,
        status = Items.ACTIVE,
        postDate = datetime.datetime.now,
        timesReported = 0 )
    i.save()
    print("Adding {}".format(i.title))
    return HttpResponse("resetting {}".format(i.title)) #change success value
