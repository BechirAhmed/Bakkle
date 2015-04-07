from django.shortcuts import render

import json
import datetime

from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.core import serializers
from django.views.decorators.csrf import csrf_exempt

from .models import Items
from account.models import Account

@csrf_exempt
def index(request):
    item_list = Items.objects.all()
    context = {
        'item_list': item_list,
    }
    return render(request, 'items/index.html', context) 

@csrf_exempt
def detail(request, item_id):
    item = get_object_or_404(Items, pk=item_id)
    urls = item.imageUrls.split(',');
    context = {
        'item': item,
        'urls': urls,
    }
    return render(request, 'items/detail.html', context) 

@csrf_exempt
def feed(request):
    #TODO: need to confirm order to display, chrono?, closest? "magic"?
    #TODO: Get items for <USERID>
    # response_data = { 'now': timezone.now().__str__(),
    #                   'item-list': Items.objects.order_by('-post_date')[:10] }
    # print(len(response_data['item-list']))
    # if len(response_data['item-list'])<1:
    #     return ""
    # return HttpResponse(json.dumps(response_data), content_type="application/json")
    return ""

@csrf_exempt
def reset(request):
    #TODO: hardcoded values
    item_expire_time=7 #days
    #TODO: Change to POST or DELETE
    Items.objects.all().delete()
    i = Items(
        imageUrls = "https://app.bakkle.com/static/images/b8347df.jpg",
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
        imageUrls = "https://app.bakkle.com/static/images/b8348df.jpg",
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
    i.save()
    i = Items(
        imageUrls = "https://app.bakkle.com/static/images/b8349df.jpg,https://app.bakkle.com/static/images/b8350df.jpg",
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

