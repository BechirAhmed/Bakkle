from django.shortcuts import render

import json
import datetime
import md5
import os

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
    for i in range (1, settings.MAX_ITEM_IMAGE + 1):
        # Get the image from the request (of format imageX where X is the image number)
        imageData = request.POST.get('image' + str(i), "" )

        # Check to see if image data is present
        if imageData != None and imageData != "":
            # Convert the data to an image from base64
            image = imageData.decode('base64')

            # Get the filepath which includes the filename to save the image to (see helper method)
            filepath = make_filepath()

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

    if (item_id == None or item_id = ""):
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

# TODO: Pick up on the delete, sell, and spam
@csrf_exempt
@require_POST
@authenticate
def delete_item(request):
    update_status(request, Items.DELETED)

@csrf_exempt
@require_POST
@authenticate
def sell_item(request):
    update_status(request, Items.SOLD)

@csrf_exempt
@require_POST
@authenticate
def spam_item(request):
    update_status(request, Items.)

def update_status(request, status):
    # Get the item id if present (If it is present an item will be edited not added)
    item_id = request.POST.get('item_id', "")

@csrf_exempt
@require_POST
@authenticate
def feed(request):
    # TODO: need to confirm order to display, chrono?, closest? "magic"?
    # TODO: Add distance filtering here
    auth_token = request.POST.get('auth_token')

    # Check that all require params are sent and are of the right format
    if (auth_token == None or auth_token.strip() == "" or auth_token.find('_') == -1):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # get the account id 
    buyer_id = auth_token.split('_')[1]

    # get items
    items_viewed = BuyerItem.objects.filter(buyer = buyer_id)
    item_list = Items.objects.exclude(buyeritem = items_viewed)# TODO: Put back in and also test the additional filter: .exclude(seller = buyer_id).filter(Q(status = BuyerItem.ACTIVE) | Q(status = BuyerItem.PENDING))

    # get json representaion of item array
    items_json = "["
    for item in item_list:
        items_json = items_json + str(item)
    items_json = items_json + "]"

    # create json string
    response_data = "{\"status\": 1, \"feed\": " + items_json + "}"
    return HttpResponse(response_data, content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def meh(request):
    return add_Item_To_Buyer_Items(request, BuyerItem.MEH)

@csrf_exempt
@require_POST
@authenticate
def want(request):
    return add_Item_To_Buyer_Items(request, BuyerItem.WANT)

@csrf_exempt
@require_POST
@authenticate
def hold(request):
    return add_Item_To_Buyer_Items(request, BuyerItem.HOLD)

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

    return add_Item_To_Buyer_Items(request, BuyerItem.REPORT)
    
def add_Item_To_Buyer_Items(request, status):
    auth_token = request.POST.get('auth_token', "")
    item_id = request.POST.get('item_id', "")
    view_duration = request.Post.get('view_duration',"")

    # Check that all require params are sent and are of the right format
    if (view_duration == None or view_duration.strip() == "") or (auth_token == None or auth_token.strip() == "" or auth_token.find('_') == -1) or (item_id == None or item_id.strip() == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")
        
    # get the account id 
    buyer_id = auth_token.split('_')[1]

    # get the item
    item = get_object_or_404(Items, pk=item_id)

    # Create or update the buyer item
    buyer_item = BuyerItem.objects.get_or_create(
        buyer = get_object_or_404(Account, pk=buyer_id),
        item = item,
        defaults = { 'status': status, 'confirmed_price': item.price })[0]
    buyer_item.status = status
    buyer_item.confirmed_price = item.price
    buyer_item.view_duration = Decimal(view_duration)
    buyer_item.save()

    response_data = { 'status':1 }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

# Image uploading
# TODO: Finish/test image uploading
# TODO: Remove commented out code if new method for image uploading works
# class UploadFileForm(forms.Form):
#     file = forms.FileField()

# @csrf_exempt
# @require_POST
# def upload_file(request):
#     form = UploadFileForm(request.POST, request.FILES)
#     item_id = request.POST.get('item_id', "")
#     if item_id == None or item_id.strip() == "":
#         print("Doesn't have item id")
#         response_data = { "status":0, "error": "A required parameter was not provided." }
#         return HttpResponse(json.dumps(response_data), content_type="application/json")
    
#     item = get_object_or_404(Items, pk=item_id)

#     if form.is_valid():
#         filepath = handle_uploaded_file(request.FILES['file'])
#         item.image_urls = item.image_urls + "," + filepath
#         item.save()
#         response_data = { 'status':1 }
#         return HttpResponse(json.dumps(response_data), content_type="application/json")
#     else:
#         print("Form isn't valid")
#         response_data = { "status":0, "error": "Image form was not valid." }
#         return HttpResponse(json.dumps(response_data), content_type="application/json")


# def handle_uploaded_file(file):
#     filepath = make_filepath()
#     print("The filepath for the image is: " + filepath)
#     if not os.path.exists(os.path.dirname(filepath)):
#         os.makedirs(os.path.dirname(filepath))
#     destination_file = open(filepath, 'wb+')
#     print("Opened destination file.")
#     for chunk in file.chunks():
#         destination_file.write(chunk)
#     destination_file.close()
#     return filepath

def make_filepath():
    path = datetime.datetime.now().strftime('%Y\\%m\\%d\\')
    filename = (md5.new(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")).hexdigest())[0:10] + ".png"
    return os.path.join(settings.MEDIA_ROOT, path, filename)

# TODO: Remove eventually. Testing data.
@csrf_exempt
def reset(request):
    #TODO: hardcoded values
    item_expire_time=7 #days
    account_id = 2
    #TODO: Change to POST or DELETE
    Items.objects.all().delete()
    BuyerItem.objects.all().delete()
    i = Items(
        image_urls = "https://app.bakkle.com/img/b83bdbd.png",
        title = "Orange Push Mower",
        description = "Year old orange push mower. Some wear and sun fadding. Was kept outside and not stored in shed.",
        location = "39.417672,-87.330438",
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
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
        seller = get_object_or_404(Account, pk=account_id),
        price = 65.99,
        tags = "iPhone6, cracked, damaged",
        method = Items.DELIVERY,
        status = Items.ACTIVE,
        post_date = datetime.datetime.now,
        times_reported = 0 )
    i.save()

    print("Adding {}".format(i.title))
    return HttpResponse("resetting {}".format(i.title)) #change success value

