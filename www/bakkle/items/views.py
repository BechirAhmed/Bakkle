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

from .models import Items, BuyerItem
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
    urls = item.image_urls.split(',');
    context = {
        'item': item,
        'urls': urls,
    }
    return render(request, 'items/detail.html', context) 

@csrf_exempt
def add_item(request):
    if request.method == "POST" or request.method == "PUT":
        image_urls = request.POST.get('device_token', "")
        title = request.POST.get('title')
        description = request.POST.get('description', "")
        location = request.POST.get('location')
        seller_id = request.POST.get('account_id')
        price = request.POST.get('price')
        tags = request.POST.get('tags',"")
        method = request.POST.get('method')
        # TODO: Pick up here on MONDAY

        response_data = { 'status':1 }
        return HttpResponse(json.dumps(response_data), content_type="application/json")
    else:
        raise Http404("Wrong method, use POST")

@csrf_exempt
def edit_item(request):
    if request.method == "POST" or request.method == "PUT":

        response_data = { 'status':1 }
        return HttpResponse(json.dumps(response_data), content_type="application/json")
    else:
        raise Http404("Wrong method, use POST")

@csrf_exempt
def feed(request):
    if request.method == "POST" or request.method == "PUT":
        #TODO: need to confirm order to display, chrono?, closest? "magic"?
        #TODO: Get items for <USERID>
        # TODO: Add distance filtering here
        buyer_id = request.POST.get('account_id')
        items_viewed = BuyerItem.objects.filter(buyer = buyer_id)
        item_list = Items.objects.exclude(buyeritem = items_viewed).exclude(seller = buyer_id)
        response_data = "{'status': 1, 'feed': " + serializers.serialize('json', item_list) + "}"
        return HttpResponse(response_data, content_type="application/json")
    else:
        raise Http404("Wrong method, use POST")

@csrf_exempt
def meh(request):
    if request.method == "POST" or request.method == "PUT":
        return add_Item_To_Buyer_Items(request, BuyerItem.MEH)
    else:
        raise Http404("Wrong method, use POST")


@csrf_exempt
def want(request):
    if request.method == "POST" or request.method == "PUT":
        return add_Item_To_Buyer_Items(request, BuyerItem.WANT)
    else:
        raise Http404("Wrong method, use POST")

@csrf_exempt
def hold(request):
    if request.method == "POST" or request.method == "PUT":
        return add_Item_To_Buyer_Items(request, BuyerItem.HOLD)
    else:
        raise Http404("Wrong method, use POST")

@csrf_exempt
def report(request):
    if request.method == "POST" or request.method == "PUT":
        item_id = request.POST.get('item_id')
        item = get_object_or_404(Items, pk=item_id)
        item.times_reported = item.times_reported + 1
        item.save()
        return add_Item_To_Buyer_Items(request, BuyerItem.REPORT)
    else:
        raise Http404("Wrong method, use POST")

def add_Item_To_Buyer_Items(request, status):
    buyer_id = request.POST.get('account_id')
    item_id = request.POST.get('item_id')

    if buyer_id == None or item_id == None:
        return "" # TODO: Need better response

    item = get_object_or_404(Items, pk=item_id)

    buyer_item = BuyerItem.objects.get_or_create(
        buyer = get_object_or_404(Account, pk=buyer_id),
        item = item,
        defaults = { 'status': status, 'confirmed_price': item.price })[0]
    buyer_item.status = status
    buyer_item.confirmed_price = item.price
    buyer_item.save()
    response_data = { 'status':1 }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
def reset(request):
    #TODO: hardcoded values
    item_expire_time=7 #days
    #TODO: Change to POST or DELETE
    Items.objects.all().delete()
    BuyerItem.objects.all().delete()
    i = Items(
        image_urls = "https://app.bakkle.com/img/b8347df.jpg",
        title = "Orange Push Mower",
        description = "Year old orange push mower. Some wear and sun fadding. Was kept outside and not stored in shed.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 50.25,
        tags = "lawnmower, orange, somewear",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/b8348df.jpg",
        title = "Rabbit Push Mower",
        description = "Homemade lawn mower. Includes rabbit and water container.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 10.99,
        tags = "lawnmower, homemade, rabbit",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/b8349df.jpg,https://app.bakkle.com/img/b8350df.jpg",
        title = "iPhone 6 Cracked",
        description = "iPhone 6. Has a cracked screen. Besides screen phone is in good condition.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 65.99,
        tags = "iPhone6, cracked, damaged",
        method = Items.DELIVERY,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    # b = BuyerItem(
    #     buyer = i.seller,
    #     item = i,
    #     confirmed_price = i.price,
    #     status = BuyerItem.WANT )
    # b.save()

    print("Adding {}".format(i.title))
    return HttpResponse("resetting {}".format(i.title)) #change success value

