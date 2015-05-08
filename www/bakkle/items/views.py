from django.shortcuts import render

import json
import datetime
import md5
import os
import base64

import random
from boto.s3.connection import S3Connection
from boto.s3.key import Key

from django.http import HttpResponse, HttpResponseRedirect, Http404
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.core import serializers
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.db.models import Q
from decimal import *
from django import forms

from .models import Items, BuyerItem
from account.models import Account
from common import authenticate
from django.conf import settings

MAX_ITEM_IMAGE = 5

config = {}
config['S3_BUCKET'] = 'com.bakkle.prod'
config['AWS_ACCESS_KEY'] = 'AKIAJIE2FPJIQGNZAMVQ' # server to s3
config['AWS_SECRET_KEY'] = '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'

config['AWS_ACCESS_KEY'] = 'AKIAJUCSHZSTNFVMEP3Q' # pethessa
config['AWS_SECRET_KEY'] = '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'


#--------------------------------------------#
#               Web page requests            #
#--------------------------------------------#
@csrf_exempt
def index(request):
    # List all items (this is for web viewing of data only)
    item_list = Items.objects.all()
    context = {
        'item_list': item_list,
    }
    return render(request, 'items/index.html', context) 

@csrf_exempt
def detail(request, item_id):
    # get the item with the item id (this is for web viewing of data only)
    item = get_object_or_404(Items, pk=item_id)
    urls = item.image_urls.split(',');
    context = {
        'item': item,
        'urls': urls,
    }
    return render(request, 'items/detail.html', context)

#--------------------------------------------#
#               Item Methods                 #
#--------------------------------------------#
config['local_image_path'] = '/bakkle/www/img/'
def handle_file_local(image_key, f):
    full_path = config['local_image_path']+image_key
    print("Storing {} to {}".format(image_key, full_path))
    local_destination = open(full_path, 'wb+')
    for chunk in f.chunks():
        local_destination.write(chunk)
    local_destination.close()

def handle_file_s3(image_key, f):
    full_path = config['local_image_path']+image_key
    print("Storing {} to S3 bucket {} as {}".format(full_path, config['S3_BUCKET'], image_key))
    conn = S3Connection(config['AWS_ACCESS_KEY'], config['AWS_SECRET_KEY'])
    #bucket = conn.create_bucket('com.bakkle.prod')
    bucket = conn.get_bucket(config['S3_BUCKET'])
    k = Key(bucket)
    k.key = image_key
    # http://boto.readthedocs.org/en/latest/s3_tut.html
    k.set_contents_from_filename(full_path)
    k.set_acl('public-read')
    return "https://s3-us-west-2.amazonaws.com/com.bakkle.prod/" + image_key
    #1_1b059fef000326dd9804173451a83dbf.jpg
    # TODO: Setup connection pool and queue for uploading at volume


@csrf_exempt
@require_POST
#@authenticate
def imgupload(request):
    # Get the authentication code
    auth_token = request.GET.get('auth_token')
    print("AT: {}".format(auth_token))

    seller_id = auth_token.split('_')[1]
    if request.method == 'POST':
        uhash = hex(random.getrandbits(128))[2:-1]
        image_key = "{}_{}.jpg".format(seller_id, uhash)
        handle_file_local(image_key, request.FILES['image'])
        handle_file_s3(image_key, request.FILES['image'])

    response_data = { "status": 1 }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def add_item(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')

    # TODO: Handle location
    # Get the rest of the necessary params from the request
    title = request.POST.get('title', "")
    description = request.POST.get('description', "")
    location = request.POST.get('location')
    seller_id = auth_token.split('_')[1]
    price = request.POST.get('price')
    tags = request.POST.get('tags',"")
    method = request.POST.get('method')

    # Get the item id if present (If it is present an item will be edited not added)
    item_id = request.POST.get('item_id', "")

    # Ensure that required fields are present otherwise send back a failed status
    if (title == None or title == "") or (tags == None or tags == "") or (price == None or price == "") or (method == None or method == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # Ensure that the price can be converted to a decimal otherwise send back a failed status
    try:
        price = Decimal(price)
    except ValueError:
        response_data = { "status":0, "error": "Price was not a valid decimal." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # Check for the image params. The max number is 5 and is defined in settings
    image_urls = ""
    for i in range (1, MAX_ITEM_IMAGE + 1):
        # Get the image from the request (of format imageX where X is the image number)
        imageData = request.POST.get('image' + str(i), "" )

        # Check to see if image data is present
        if imageData != None and imageData != "":
            # Convert the data to an image from base64
            image = base64.decodestring(imageData)#.decode('base64')

            # Get the filepath which includes the filename to save the image to (see helper method)
            filepath = make_filepath(seller_id)

            # if the filepath does not exist, create it (this includes folder and file creation)
            if not os.path.exists(os.path.dirname(filepath)):
                os.makedirs(os.path.dirname(filepath))

            # Open the created file for writing
            destination_file = open(filepath, 'wb+')

            # Write the image data to the file and close it
            destination_file.write(image)
            destination_file.close()

            # Add the new image url to the image_urls for the item
            image_urls = image_urls + filepath + ","

    if (item_id == None or item_id == ""):
        # Create the item
        item = Items.objects.create(
            title = title,
            seller_id = seller_id,
            description = description,
            location = "",
            price = price,
            tags = tags,
            method = method,
            image_urls = image_urls,
            status = Items.ACTIVE)
        item.save()
    else:
        # Else get the item
        item = get_object_or_404(Items, pk=item_id);

        # Remove all previous images
        old_urls = item.image_urls.split(",")
        for url in old_urls:
            # if image exists remove the file
            if os.path.exists(url):
                os.remove(url)

        # Update item fields
        item.title = title
        item.description = description
        item.tags = tags
        item.price = price
        item.method = method
        item.image_urls = image_urls
        item.save()

    response_data = { "status":1 }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def delete_item(request):
    return update_status(request, Items.DELETED)

@csrf_exempt
@require_POST
@authenticate
def sell_item(request):
    return update_status(request, Items.SOLD)

# This will only be called by the system if an Item has been reported X amount of times.
# TODO: implement this in the report 
@csrf_exempt
def spam_item(request):
    return update_status(request, Items.SPAM)

@csrf_exempt
@require_POST
@authenticate
def feed(request):
    # TODO: need to confirm order to display, chrono?, closest? "magic"?
    auth_token = request.POST.get('auth_token')

    # TODO: Use these for filtering
    search_text = request.POST.get('search_text')
    filter_distance = request.POST.get('filter_distance')
    filter_price = request.POST.get('filter_price')
    filter_number = request.POST.get('filter_number')

    # Check that all require params are sent and are of the right format
    if (auth_token == None or auth_token.strip() == "" or auth_token.find('_') == -1):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # get the account id 
    buyer_id = auth_token.split('_')[1]

    # get items
    items_viewed = BuyerItem.objects.filter(buyer = buyer_id)

    item_list = None
    if(search_text != None and search_text != ""):
        search_text.strip()
        item_list = Items.objects.exclude(buyeritem = items_viewed).filter(Q(status = BuyerItem.ACTIVE) | Q(status = BuyerItem.PENDING)).filter(Q(tags__contains=search_text))
    else:
        item_list = Items.objects.exclude(buyeritem = items_viewed).filter(Q(status = BuyerItem.ACTIVE) | Q(status = BuyerItem.PENDING))

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = get_item_dictionary(item)
        item_array.append(item_dict)

    response_data = { 'status': 1, 'feed': item_array }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def meh(request):
    return add_item_to_buyer_items(request, BuyerItem.MEH)

@csrf_exempt
@require_POST
@authenticate
def want(request):
    return add_item_to_buyer_items(request, BuyerItem.WANT)

@csrf_exempt
@require_POST
@authenticate
def hold(request):
    return add_item_to_buyer_items(request, BuyerItem.HOLD)

@csrf_exempt
@require_POST
@authenticate
def report(request):
    item_id = request.POST.get('item_id')

    # Check that all require params are sent and are of the right format
    if (item_id == None or item_id.strip() == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")
     
    # Get item and update the times reported
    item = get_object_or_404(Items, pk=item_id)
    item.times_reported = item.times_reported + 1
    item.save()

    return add_item_to_buyer_items(request, BuyerItem.REPORT)


#--------------------------------------------#
#            Buyer Item Methods              #
#--------------------------------------------#
@csrf_exempt
@require_POST
@authenticate
def buyer_item_meh(request):
    return add_item_to_buyer_items(request, BuyerItem.MEH)

@csrf_exempt
@require_POST
@authenticate
def buyer_item_want(request):
    return add_item_to_buyer_items(request, BuyerItem.WANT)

#--------------------------------------------#
#           Seller's Item Methods            #
#--------------------------------------------#
@csrf_exempt
@require_POST
@authenticate
def get_seller_items(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    seller_id = auth_token.split('_')[1]

    item_list = Items.objects.filter(Q(seller=seller_id, status=Items.ACTIVE) | Q(seller=seller_id, status=Items.PENDING))

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = get_item_dictionary(item)
        item_array.append(item_dict)

    # create json string
    response_data = {'status': 1, 'seller_garage': item_array}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def get_seller_transactions(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    seller_id = auth_token.split('_')[1]

    item_list = Items.objects.filter(seller=seller_id, status=Items.SOLD)

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = get_item_dictionary(item)
        item_array.append(item_dict)

    # create json string
    response_data = {'status': 1, 'seller_history': item_array}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

#--------------------------------------------#
#           Buyer's Item Methods             #
#--------------------------------------------#
@csrf_exempt
@require_POST
@authenticate
def get_buyers_trunk(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    buyer_id = auth_token.split('_')[1]

    item_list = BuyerItem.objects.filter(Q(buyer=buyer_id, status=BuyerItem.WANT) | Q(buyer=buyer_id, status=BuyerItem.PENDING) | Q(buyer=buyer_id, status=BuyerItem.NEGOCIATING))

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = get_buyer_item_dictionary(item)
        item_array.append(item_dict)

    response_data = { 'status': 1, 'buyers_trunk': item_array }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def get_holding_pattern(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    buyer_id = auth_token.split('_')[1]

    item_list = BuyerItem.objects.filter(buyer=buyer_id, status=BuyerItem.HOLD)

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = get_buyer_item_dictionary(item)
        item_array.append(item_dict)

    response_data = { 'status': 1, 'holding_pattern': item_array}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def get_buyer_transactions(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    buyer_id = auth_token.split('_')[1]

    item_list = BuyerItem.objects.filter(buyer=buyer_id, status=BuyerItem.SOLD_TO)

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = get_buyer_item_dictionary(item)
        item_array.append(item_dict)

    response_data = { 'status': 1, 'buyer_history': item_array}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

#--------------------------------------------#
#             Helper Functions               #
#--------------------------------------------#
# Helper for filepath generation
def make_filepath(seller_id):
    filename = str(seller_id) + "_" + (md5.new(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")).hexdigest())[0:10] + ".png"
    filepath = os.path.join(os.getcwd(), "..", "img", datetime.datetime.now().strftime('%Y-%m'), filename)
    print("Filepath\n")
    print(filepath)
    return filepath

# Helper for creating buyer items
def add_item_to_buyer_items(request, status):
    auth_token = request.POST.get('auth_token', "")
    item_id = request.POST.get('item_id', "")
    view_duration = request.POST.get('view_duration',"")
    buyer_item_id = request.POST.get('buyer_item_id', "")

    # Check that all require params are sent and are of the right format
    if (view_duration == None or view_duration.strip() == "") or (auth_token == None or auth_token.strip() == "" or auth_token.find('_') == -1) or (item_id == None or item_id.strip() == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")
    
    try:
        view_duration = Decimal(view_duration)
    except ValueError:
        response_data = { "status":0, "error": "Price was not a valid decimal." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # get the account id 
    buyer_id = auth_token.split('_')[1]

    # get the item
    item = get_object_or_404(Items, pk=item_id)

    if (buyer_item_id == None or buyer_item_id == ""):
        # Create or update the buyer item
        buyer_item = BuyerItem.objects.create(
            buyer = get_object_or_404(Account, pk=buyer_id),
            item = item,
            status = status, 
            confirmed_price = item.price,
            view_duration = 0)

        # If the item seller is the same as the buyer mark it as their item instead of the status
        # TODO: Eventually put this back in to prevent errors from user trying to buy their own item
        # if(str(item.seller.id) == str(buyer_id)):
        #     print("Are same")
        #     buyer_item.status = BuyerItem.MY_ITEM
        # else:
        #     buyer_item.status = status

        print(BuyerItem.MY_ITEM)
        buyer_item.confirmed_price = item.price
        buyer_item.view_duration = view_duration
        buyer_item.save()
    else:
        buyer_item = get_object_or_404(BuyerItem, pk=buyer_item_id)

        # Update fields
        # If the item seller is the same as the buyer mark it as their item instead of the status
        # TODO: Eventually put this back in to prevent errors from user trying to buy their own item
        # if(str(item.seller.id) == str(buyer_id)):
        #     print("Are same")
        #     buyer_item.status = BuyerItem.MY_ITEM
        # else:
        #     buyer_item.status = status

        # buyer_item.confirmed_price = item.price
        # buyer_item.view_duration = view_duration
        # buyer_item.save()

    response_data = { 'status':1 }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

# Helper for updating Item Statuses
def update_status(request, status):
    # Get the item id 
    item_id = request.POST.get('item_id', "")

    # Ensure that required fields are present otherwise send back a failed status
    if (item_id == None or item_id == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # Get the item
    item = Items.objects.get(pk=item_id)
    item.status = status
    item.save()
    response_data = { "status":1 }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

# Helper for making an Item into a dictionary for JSON
def get_item_dictionary(item):
    images = []
    hashtags = []

    urls = item.image_urls.split(",")
    for url in urls:
        if url != "" and url != " ":
            images.append(url)

    tags = item.tags.split(",")
    for tag in tags:
        if tag != "" and tag != " ":
            hashtags.append(tag)

    seller_dict = get_account_dictionary(item.seller)
    item_dict = {'pk':item.pk, 
        'description': item.description, 
        'seller': seller_dict,
        'image_urls': images,
        'tags': hashtags,
        'title': item.title,
        'location': item.location,
        'price': str(item.price),
        'method': item.method,
        'status': item.status,
        'post_date': item.post_date.strftime("%Y-%m-%d %H:%M:%S")}
    return item_dict

# Helper for getting account information for items for JSON
# TODO: may need to add more fields
def get_account_dictionary(account):
    seller_dict = {'pk': account.pk, 
        'display_name': account.display_name, 
        'seller_rating': account.seller_rating,
        'buyer_rating': account.buyer_rating,
        'seller_location': account.seller_location}
    return seller_dict

# Helper for making a BuyerItem into a dictionary for JSON
def get_buyer_item_dictionary(buyer_item):
    buyer_dict = get_account_dictionary(buyer_item.buyer)
    item_dict = get_item_dictionary(buyer_item.item)

    buyer_item_dict = {'pk': buyer_item.pk,
        'view_time': buyer_item.view_time.strftime("%Y-%m-%d %H:%M:%S"),
        'view_duration': str(buyer_item.view_duration),
        'status': buyer_item.status,
        'confirmed_price': str(buyer_item.confirmed_price),
        'accepted_sale_price': buyer_item.accepted_sale_price,
        'item': item_dict,
        'buyer': buyer_dict}
    return buyer_item_dict

# Helper to return the delivery methods for items
@csrf_exempt
@require_POST
@authenticate
def get_delivery_methods(request):
    response_data = { 'status': 1, 'deliver_methods': Items.METHOD_CHOICES}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

#--------------------------------------------#
#               Testing Items                #
#--------------------------------------------#
# TODO: Remove eventually. Testing data.
@csrf_exempt
def reset(request):
    #TODO: hardcoded values
    item_expire_time=7 #days
    #TODO: Change to POST or DELETE
    Items.objects.all().delete()
    BuyerItem.objects.all().delete()

    # create dummy account
    try:
        a = Account.objects.get(
            facebook_id="1020420",
            display_name="Test Seller",
            email="testseller@bakkle.com" )
    except Account.DoesNotExist:
        a = Account(
            facebook_id="1020420",
            display_name="Test Seller",
            email="testseller@bakkle.com" )
        a.save()

    i = Items(
        image_urls = "https://app.bakkle.com/img/b83bdbd.png",
        title = "Orange Push Mower",
        description = "Year old orange push mower. Some wear and sun fadding. Was kept outside and not stored in shed.",
        location = "39.417672,-87.330438",
        seller = a,
        price = 50.25,
        tags = "lawnmower, orange, somewear",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/WP_20150417_09_47_27_Pro.jpg",
        title = "Oil change",
        description = "will change your cars oil at your location, $ 19.95.",
        location = "39.417672,-87.330438",
        seller = a,
        price = 19.95,
        tags = "service, oil change",
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
        seller = a,
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
        description = "MacBook Pro 15\" Mid 2014 i7. 2.2 GHz, 16 GB RAM, 256 GB SSD. Very little use, needed a lighter model so switched to MacBook air. Includes original box, power cord, etc.",
        location = "39.417672,-87.330438",
        seller = a,
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
        seller = a,
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
        seller = a,
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
        seller = a,
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
        seller = a,
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
        seller = a,
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
        seller = a,
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
        seller = a,
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
        description = "Blender, used. Runs great. 5 speeds with turbo",
        location = "39.417672,-87.330438",
        seller = a,
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
        description = "Playstation 2 with controller. Broken, needs laser cleaning. Won't read discs.",
        location = "39.417672,-87.330438",
        seller = a,
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
        description = "Basic home security system.",
        location = "39.417672,-87.330438",
        seller = a,
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
        description = "Propane barbeque grill with side burner. 2 years old worth $200 from Lowes. Full propane bottle included.",
        location = "39.417672,-87.330438",
        seller = a,
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
        description = "MKTG marketing text (instructor edition) by Lam, hair, mcdaniel and Essentials of Entrepreneurship and Small Business Management by Normal M. Scarborough (7th global edition).",
        location = "39.417672,-87.330438",
        seller = a,
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
        description = "Nike women's air max shoes size 6 1/2. Never worn outside.",
        location = "39.417672,-87.330438",
        seller = a,
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
        seller = a,
        price = 10.99,
        tags = "lawnmower, homemade, rabbit",
        method = Items.PICK_UP,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()
    i = Items(
        image_urls = "https://app.bakkle.com/img/b8349df.jpg",
        title = "iPhone 6 Cracked",
        description = "iPhone 6. Has a cracked screen. Besides screen phone is in good condition.",
        location = "39.417672,-87.330438",
        seller = a,
        price = 65.99,
        tags = "iPhone6, cracked, damaged",
        method = Items.DELIVERY,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()

    print("Adding {}".format(i.title))
    return HttpResponse("resetting {}".format(i.title)) #change success value

