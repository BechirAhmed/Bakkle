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
        response_data = "{\"status\": 1, \"feed\": " + serializers.serialize('json', item_list) + "}"
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
        image_urls = "https://app.bakkle.com/img/b83bdbd.png",
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
        image_urls = "https://app.bakkle.com/img/00e0e_5WQCcunAcn_600x450.jpg",
        title = "Flat screen LED TV",
        description = "Flat screen LED LCD TV. Brand new in box, 4 HDMI ports and Netflix built in.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 107.00,
        tags = "tv, led, netflix",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00n0n_eerJtWHsBKc_600x450.jpg",
        title = "15\" MacBook pro",
        description = "MacBook Pro 15\"Mid 2014 i7. 2.2 GHz, 16 GB RAM, 256 GB SSD. Very little use, needed a lighter model so switched to MacBook air. Includes original box, power cord, etc.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 999.00,
        tags = "mac, apple, macbook, macbook pro",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00n0n_gonFpgUcRAe_600x450.jpg",
        title = "Paint ball gun",
        description = "Gun only, no CO2 tank. Needs new HPR piston",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 40.99,
        tags = "paintball, gun, bump paintball",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00O0O_kOqfijcw7FL_600x450.jpg",
        title = "Business law text book",
        description = "Business law text and cases, clarkson, miller, jentz, 11th edition. No marks or highlighting.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 40.99,
        tags = "textbook, business law",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00P0P_dcFyXMBIkYE_600x450.jpg",
        title = "Baseball mitt",
        description = "Louisville slugger baseball mitt, mint condition.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 30.00,
        tags = "baseball mitt",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00s0s_49F9D9EnAJ3_600x450.jpg",
        title = "Bicycle",
        description = "Pure fix fixie bicycle.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 300,
        tags = "bicycle",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00T0T_f1xeeb2KYxA_600x450.jpg",
        title = "Canon 50D",
        description = "Canon 50D digital camera. Comes with f1.8 50mm lens.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 30.00,
        tags = "canon, 50d, digital camera",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00u0u_hj2g60Tn2D7_600x450.jpg",
        title = "iPhone 5",
        description = "White Apple iphone 5. Unlocked",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 200.00,
        tags = "apple, iphone, iphone 5",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00V0V_kQXPgLCzkEl_600x450.jpg",
        title = "weights",
        description = "Premium adjustable hand barbell weight set.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 300.00,
        tags = "weights, barbell",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00W0W_hCYzWAyYAvP_600x450.jpg",
        title = "Blender",
        deescription = "Blender, used. Runs great. 5 speeds with turbo",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 12.00,
        tags = "blender",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00404_8sCApbm5Bvc_600x450.jpg",
        title = "Playstation 2",
        deescription = "Playstation 2 with controller. Broken, needs laser cleaning. Won't read discs.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 45.00,
        tags = "sony, playstation, controller",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00808_k0TscttMik5_600x450.jpg",
        title = "Baseball bat",
        deescription = "Basic home security system.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 10.00,
        tags = "baseball, security, bat",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/00909_iVAvBfYmpNm_600x450.jpg",
        title = "Gas grille",
        deescription = "Propane barbeque grill with side burner. 2 years old worth $200 from Lowes. Full propane bottle included.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 10.00,
        tags = "propane, gas, grille, barbeque, bbq",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/01313_fXdf3fNJDJC_600x450.jpg",
        title = "Marketing textbooks",
        deescription = "MKTG marketing text (instructor edition) by Lam, hair, mcdaniel and Essentials of Entrepreneurship and Small Business Management by Normal M. Scarborough (7th global edition).",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 175.00,
        tags = "marketing, textbooks",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/01313_gsH7Yan7PYA_600x450.jpg",
        title = "Nike shoes",
        deescription = "Nike women's air max shoes size 6 1/2. Never worn outside.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=1),
        price = 90.00,
        tags = "shoes, nike, womens",
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

