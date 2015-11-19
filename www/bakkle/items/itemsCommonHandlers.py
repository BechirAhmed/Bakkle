import time

import random

from boto.s3.connection import S3Connection
from boto.s3.key import Key

from decimal import *
from django.core.paginator import Paginator
from django.db.models import Q
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from django.utils import timezone

from .models import BuyerItem
from .models import Items
from account.models import Account
from account.models import Device
from chat.models import Chat

from common.methods import getNumUnreadChatsForAccount
from common.decorators import time_method
import math

from common.decorators import run_async
from django.core.mail import send_mail
from tornado.log import logging

MAX_ITEM_IMAGE = 5

config = {}
config['S3_BUCKET'] = 'com.bakkle.prod'
config['AWS_ACCESS_KEY'] = 'AKIAJIE2FPJIQGNZAMVQ'  # server to s3
config['AWS_SECRET_KEY'] = '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'

config['AWS_ACCESS_KEY'] = 'AKIAJUCSHZSTNFVMEP3Q'  # pethessa
config['AWS_SECRET_KEY'] = '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'

config['S3_URL'] = 'https://s3-us-west-2.amazonaws.com/com.bakkle.prod/'


#--------------------------------------------#
#               Web page requests            #
#--------------------------------------------#
@time_method
def index():
    # List all items (this is for web viewing of data only)
    item_list = Items.objects.all().order_by('post_date')

    return item_list


@time_method
def spam_index():
    # List all items marked by users as spam, but not actually listed as spam.
    # (this is for web viewing of data only)
    reportedItems = BuyerItem.objects.filter(status=BuyerItem.REPORT).filter(
        Q(item__status=Items.ACTIVE) |
        Q(item__status=Items.PENDING)
    ).values('item__pk')

    item_list = Items.objects.filter(
        Q(status=Items.ACTIVE) |
        Q(status=Items.PENDING)
    ).filter(pk__in=reportedItems).order_by('-post_date')

    return item_list

# @time_method
# def public_detail(request, item_id):
# get the item with the item id (this is for web viewing of data only)
#     item = get_object_or_404(Items, pk=item_id)
#     urls = item.image_urls.split(',');
#     context = {
#         'item': item,
#         'urls': urls,
#     }
#     return render(request, 'items/public_detail.html', context)


@time_method
def item_detail(item_id):
    # get the item with the item id (this is for web viewing of data only)
    item = get_object_or_404(Items, pk=item_id)
    urls = item.image_urls.split(',')
    context = {
        'item': item,
        'urls': urls,
    }
    return context


@time_method
def mark_as_spam(item_id, fromSpam):
    # Get the item
    item = Items.objects.get(pk=item_id)
    item.status = Items.SPAM
    item.save()

    if(fromSpam):
        return spam_index()

    return index()


@time_method
def mark_as_deleted(item_id, fromSpam):
    # Get the item id
    item = Items.objects.get(pk=item_id)
    item.status = Items.DELETED
    item.save()

    if(fromSpam):
        return spam_index()

    return index()

#--------------------------------------------#
#               Item Methods                 #
#--------------------------------------------#


@time_method
def add_item(title, description, location, seller_id, price, tags, notifyFlag, item_id, images, videos):
    # Get the authentication code

    # Get the rest of the necessary params from the request

    # Get the item id if present (If it is present an item will be edited not
    # added)

    # Ensure that required fields are present otherwise send back a failed status
    # Ensure that the price can be converted to a decimal otherwise send back
    # a failed status
    try:
        price = Decimal(price)
    except ValueError:
        response_data = {
            "status": 0, "error": "Price was not a valid decimal."}
        return response_data

    # Check for the image params. The max number is 5 and is defined in
    # settings
    image_urls = imgupload(images, videos, seller_id)

    TWOPLACES = Decimal(10) ** -6

    if (item_id is None or item_id == ""):
        # Create the item
        item = Items.objects.create(
            title=title,
            seller_id=seller_id,
            description=description,
            latitude=Decimal(location.split(",")[0]).quantize(TWOPLACES),
            longitude=Decimal(location.split(",")[1]).quantize(TWOPLACES),
            price=price,
            tags=tags,
            image_urls=image_urls,
            status=Items.ACTIVE)
        item.save()
        if(notifyFlag is None or notifyFlag == "" or int(notifyFlag) != 0):
            notify_all_new_item(
                u"New: ${} - {}".format(item.price, item.title))
        logging.info("[AddItem] adding item: " + str(item.pk))
    else:
        # Else get the item
        try:
            item = Items.objects.get(pk=item_id)
            logging.info("[EditItem] editing item: " + str(item_id))
        except Items.DoesNotExist:
            item = None
            response_data = {
                "status": 0, "error": "Item {} does not exist.".format(item_id)}
            return response_data

        # TODO: fix this
        # Remove all previous images
        # old_urls = item.image_urls.split(",")
        # for url in old_urls:
        # remove image from S3
        #     handle_delete_file_s3(url)

        # Update item fields

        item.title = title
        item.description = description
        item.tags = tags
        item.price = price
        item.image_urls = image_urls
        item.save()

    logging.info("[Add/EditItem] done with item: " + str(item_id))

    response_data = {"status": 1, "item_id": item.id}

    if(image_urls is not None and len(image_urls) != 0):
        response_data['image_url'] = image_urls.split(',')[0]
    else:
        response_data['image_url'] = None

    return response_data


@time_method
def add_item_no_image(title, description, location, seller_id, price, tags, method, notifyFlag, item_id):
    # Get the authentication code

    # Get the rest of the necessary params from the request

    # Get the item id if present (If it is present an item will be edited not
    # added)

    # Ensure that required fields are present otherwise send back a failed
    # status
    if (title is None or title == "") or (tags is None or tags == "") or (price is None or price == "") or (method is None or method == ""):
        response_data = {
            "status": 0, "error": "A required parameter was not provided."}
        return response_data

    # Ensure that the price can be converted to a decimal otherwise send back
    # a failed status
    try:
        price = Decimal(price)
    except ValueError:
        response_data = {
            "status": 0, "error": "Price was not a valid decimal."}
        return response_data

    TWOPLACES = Decimal(10) ** -6

    response_data = {"status": 1, "item_id": -1}
    return response_data


@run_async
def notify_all_new_item(message):
    # Get all devices

    if message is None or message == "":
        response_data = {"status": 0, "error": "No message supplied"}
        return response_data

    accounts = Account.objects.filter()
    for account in accounts:
        devices = Device.objects.filter(account_id=account)

        badge = getNumUnreadChatsForAccount(account.pk)

        # notify each device
        for device in devices:
            # lookup number of unread messages

            device.send_notification(message, badge)

    response_data = {"status": 1}
    return response_data


@time_method
def delete_item(item_id):
    return update_status(item_id, Items.DELETED)


# This will only be called by the system if an Item has been reported X amount of times.
# TODO: implement this in the report
@time_method
def spam_item(item_id):
    return update_status(item_id, Items.SPAM)


@time_method
def feed(buyer_id, device_uuid, user_location, search_text, filter_distance, filter_price):
    logging.info("feed buyer_id={}, device_uuid={}, user_location={}, search_text={}, filter_distance={}, filter_price={}".format(buyer_id, device_uuid, user_location, search_text, filter_distance, filter_price))

    startTime = time.time()

    MAX_ITEM_PRICE = 100
    MAX_ITEM_DISTANCE = 100
    RETURN_ITEM_ARRAY_SIZE = 20

    # Check that location was in the correct format
    location = ""
    lat = 0
    lon = 0
    try:
        positions = user_location.split(",")
        if len(positions) < 2:
            response_data = {
                "status": 0, "error": "User location was not in the correct format."}
            return response_data
        else:
            TWOPLACES = Decimal(10) ** -2
            lat = float(Decimal(positions[0]).quantize(TWOPLACES))
            lon = float(Decimal(positions[1]).quantize(TWOPLACES))
            location = str(lat) + "," + str(lon)
    except ValueError:
        response_data = {
            "status": 0, "error": "Latitude or Longitude was not a valid decimal."}
        return response_data

    logging.debug('Time after %s: %0.2f ms' %
                  ("parsing locations", (time.time() - startTime) * 1000.0))
    startTime = time.time()

    # horizontal range
    lonRange = filter_distance / (math.cos(lat / 180 * math.pi) * 69.172)
    lonMin = lon - lonRange
    lonMax = lon + lonRange

    # vertical range
    latRange = filter_distance / 69.172
    latMin = lat - latRange
    latMax = lat + latRange

    logging.debug('Time after %s: %0.2f ms' %
                  ("getting item range", (time.time() - startTime) * 1000.0))
    startTime = time.time()

    # get the account object and the device and update location
    try:
        if buyer_id != 0:
           account = Account.objects.get(id=buyer_id)
           account.user_location = location
           account.save()

        # Get the device
        device = Device.objects.get(uuid=device_uuid)
        device.user_location = location
        device.save()
    except Account.DoesNotExist:
        account = None
        response_data = {
            "status": 0, "error": "Account {} does not exist.".format(buyer_id)}
        return response_data
    except Device.DoesNotExist:
        device = None
        response_data = {
            "status": 0, "error": "Device {} does not exist.".format(device_uuid)}
        return response_data

    logging.debug('Time after %s: %0.2f ms' %
                  ("updating locations", (time.time() - startTime) * 1000.0))
    startTime = time.time()

    # get items (when in guest mode filter on uuid not buyer account id)
    items_viewed = None
    if buyer_id==0:
       logging.info("Getting items for UUID={}".format(device_uuid))
       #import pdb; pdb.set_trace()
       items_viewed = BuyerItem.objects.filter(uuid=device_uuid).values('item')
    else:
       logging.info("Getting items for buyer_id={}".format(buyer_id))
       items_viewed = BuyerItem.objects.filter(buyer=buyer_id).values('item')
    appFlavor = account.app_flavor

    item_list = None
    users_list = None

    if(search_text is not None and search_text != ""):
        search_text.strip()

        # if filter price is 100+, ignore filter.
        if(filter_price == MAX_ITEM_PRICE):
            item_list = Items.objects.exclude(pk__in=items_viewed).filter(seller__app_flavor=appFlavor).filter(Q(status=Items.ACTIVE) | Q(
                status=Items.PENDING)).filter(Q(tags__contains=search_text) | Q(title__contains=search_text)).order_by('-post_date')[:RETURN_ITEM_ARRAY_SIZE]
        else:
            item_list = Items.objects.exclude(pk__in=items_viewed).filter(seller__app_flavor=appFlavor).filter(Q(price__lte=filter_price)).filter(Q(status=Items.ACTIVE) | Q(
                status=Items.PENDING)).filter(Q(tags__contains=search_text) | Q(title__contains=search_text)).order_by('-post_date')[:RETURN_ITEM_ARRAY_SIZE]
    else:

        # if filter price is 100+, ignore filter.
        if(filter_distance == MAX_ITEM_DISTANCE):
            if(filter_price == MAX_ITEM_PRICE):
                item_list = Items.objects.exclude(pk__in=items_viewed).exclude(seller__pk=buyer_id).filter(seller__app_flavor=appFlavor).filter(
                    Q(status=Items.ACTIVE) | Q(status=Items.PENDING)).order_by('-post_date')[:RETURN_ITEM_ARRAY_SIZE]
                users_list = Items.objects.filter(Q(seller__pk=buyer_id)).filter(
                    Q(status=Items.ACTIVE) | Q(status=Items.PENDING)).order_by('-post_date')[:1]
            else:
                item_list = Items.objects.exclude(pk__in=items_viewed).exclude(seller__pk=buyer_id).filter(seller__app_flavor=appFlavor).filter(
                    Q(price__lte=filter_price)).filter(Q(status=Items.ACTIVE) | Q(status=Items.PENDING)).order_by('-post_date')[:RETURN_ITEM_ARRAY_SIZE]
                users_list = Items.objects.filter(Q(seller__pk=buyer_id)).filter(
                    Q(status=Items.ACTIVE) | Q(status=Items.PENDING)).order_by('-post_date')[:1]
        else:
            if(filter_price == MAX_ITEM_PRICE):
                item_list = Items.objects.exclude(pk__in=items_viewed).exclude(seller__pk=buyer_id).filter(seller__app_flavor=appFlavor).filter(Q(status=Items.ACTIVE) | Q(
                    status=Items.PENDING)).filter(longitude__lte=lonMax, longitude__gte=lonMin, latitude__lte=latMax, latitude__gte=latMin).order_by('-post_date')[:RETURN_ITEM_ARRAY_SIZE]
                users_list = Items.objects.filter(Q(seller__pk=buyer_id)).filter(
                    Q(status=Items.ACTIVE) | Q(status=Items.PENDING)).order_by('-post_date')[:1]
            else:
                item_list = Items.objects.exclude(pk__in=items_viewed).exclude(seller__pk=buyer_id).filter(seller__app_flavor=appFlavor).filter(Q(price__lte=filter_price)).filter(
                    Q(status=Items.ACTIVE) | Q(status=Items.PENDING)).filter(longitude__lte=lonMax, longitude__gte=lonMin, latitude__lte=latMax, latitude__gte=latMin).order_by('-post_date')[:RETURN_ITEM_ARRAY_SIZE]
                users_list = Items.objects.filter(Q(seller__pk=buyer_id)).filter(
                    Q(status=Items.ACTIVE) | Q(status=Items.PENDING)).order_by('-post_date')[:1]

    item_array = []
    paginatedItems = Paginator(item_list, 100)
    numUserItems = 0

    logging.info("Num items {}".len(users_list))

    # show user's items before other items - place at top of array.
    if(users_list is not None and len(users_list) != 0):
        for item in users_list:
            if(len(BuyerItem.objects.filter(buyer__pk=buyer_id).filter(item__pk=item.pk)) == 0):
                item_dict = item.toDictionary()
                item_array.append(item_dict)

    # add all other items - show after top user item
    page = 1
    while len(item_array) < RETURN_ITEM_ARRAY_SIZE and page <= paginatedItems.num_pages:
        itemPage = paginatedItems.page(page)
        for item in itemPage.object_list:
            if (len(item_array) < RETURN_ITEM_ARRAY_SIZE):
                item_dict = item.toDictionary()
                item_array.append(item_dict)

        page += 1

    logging.debug('Time after %s: %0.2f ms' % (
        "adding feed items to return array", (time.time() - startTime) * 1000.0))
    startTime = time.time()

    response_data = {'status': 1, 'feed': item_array}
    return response_data


@time_method
def meh(buyer_id, item_id, view_duration):
    return add_item_to_buyer_items(buyer_id, item_id, view_duration, BuyerItem.MEH)


@time_method
def sold(buyer_id, item_id, view_duration):
    return add_item_to_buyer_items(buyer_id, item_id, view_duration, BuyerItem.SOLD)


@time_method
def want(buyer_id, item_id, view_duration):

    try:
        buyer = Account.objects.get(pk=buyer_id)
        item = Items.objects.get(pk=item_id)
    except Account.DoesNotExist:
        return {"status": 0, "error": "Buyer {} does not exist.".format(buyer_id)}
    except Items.DoesNotExist:
        return {"status": 0, "error": "Item {} does not exist.".format(item_id)}

    if (buyer != item.seller):
        chat = Chat.objects.get_or_create(
            item=item,
            buyer=buyer)[0]
        chat.start_time = timezone.now()
        chat.save()

    return add_item_to_buyer_items(buyer_id, item_id, view_duration, BuyerItem.WANT)


@time_method
def hold(buyer_id, item_id, view_duration):
    return add_item_to_buyer_items(buyer_id, item_id, view_duration, BuyerItem.HOLD)


@time_method
def report(buyer_id, item_id, view_duration, message=None):

    # Get item and update the times reported
    try:
        user = Account.objects.get(pk=buyer_id)
        item = Items.objects.get(pk=item_id)
    except Items.DoesNotExist:
        return {"status": 0, "error": "Item {} does not exist.".format(item_id)}
    except Account.DoesNotExist:
        return {"status": 0, "error": "Account {} does not exist.".format(buyer_id)}

    item.times_reported = item.times_reported + 1
    item.save()
    # send_mail('Item reported', 'Item has been reported by user ' + str(user.display_name), 'backend@app.bakkle.com', ['wongb@rose-hulman.edu'], fail_silently=False)

    return add_item_to_buyer_items(buyer_id, item_id, view_duration, BuyerItem.REPORT, message)


#--------------------------------------------#
#            Buyer Item Methods              #
#--------------------------------------------#
# @csrf_exempt
# @require_POST
# @authenticate
# @time_method
# def buyer_item_meh(request):
#     return add_item_to_buyer_items(request, BuyerItem.MEH)

# @csrf_exempt
# @require_POST
# @authenticate
# @time_method
# def buyer_item_want(request):
#     return add_item_to_buyer_items(request, BuyerItem.WANT)

#--------------------------------------------#
#           Seller's Item Methods            #
#--------------------------------------------#
@time_method
def get_seller_items(seller_id):

    item_list = Items.objects.filter(seller=seller_id).filter(Q(status=Items.ACTIVE) | Q(
        status=Items.PENDING) | Q(status=Items.SOLD)).order_by('-post_date').prefetch_related('buyeritem_set')

    item_array = []
    # get json representaion of item array
    for item in item_list:
        convos_with_new_message = 0

        # get the buyer items for this item
        number_of_views = 0
        number_of_meh = 0
        number_of_want = 0
        number_of_report = 0
        number_of_holding = 0
        for buyer_item in item.buyeritem_set.all():
            if buyer_item.status != BuyerItem.MY_ITEM:
                number_of_views = number_of_views + 1

            if buyer_item.status == BuyerItem.MEH:
                number_of_meh = number_of_meh + 1
            elif buyer_item.status == BuyerItem.REPORT:
                number_of_report = number_of_report + 1
            elif buyer_item.status == BuyerItem.HOLD:
                number_of_holding = number_of_holding + 1
            elif buyer_item.status == BuyerItem.WANT or buyer_item.status == BuyerItem.NEGOTIATING or buyer_item.status == BuyerItem.PENDING:
                number_of_want = number_of_want + 1

        # create the dictionary for the item and append it
        item_dict = item.toDictionary()
        item_dict['convos_with_new_message'] = convos_with_new_message
        item_dict['number_of_views'] = number_of_views
        item_dict['number_of_meh'] = number_of_meh
        item_dict['number_of_want'] = number_of_want
        item_dict['number_of_holding'] = number_of_holding
        item_dict['number_of_report'] = number_of_report
        item_array.append(item_dict)

    # create json string
    response_data = {'status': 1, 'seller_garage': item_array}
    return response_data


@time_method
def get_seller_transactions(seller_id):

    item_list = Items.objects.filter(seller=seller_id, status=Items.SOLD)

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = item.toDictionary()
        item_array.append(item_dict)

    # create json string
    response_data = {'status': 1, 'seller_history': item_array}
    return response_data

# -------------------------------------------- #
#           Buyer's Item Methods               #
# -------------------------------------------- #


@time_method
def get_buyers_trunk(buyer_id):

    item_list = BuyerItem.objects.filter(Q(buyer=buyer_id, status=BuyerItem.WANT) |
                                         Q(buyer=buyer_id, status=BuyerItem.PENDING) |
                                         Q(buyer=buyer_id, status=BuyerItem.SOLD) |
                                         Q(buyer=buyer_id, status=BuyerItem.NEGOTIATING)).exclude(item__seller__pk=buyer_id).order_by('-view_time')

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = item.toDictionary()
        item_array.append(item_dict)

    response_data = {'status': 1, 'buyers_trunk': item_array}
    return response_data


@time_method
def get_holding_pattern(buyer_id):

    item_list = BuyerItem.objects.filter(buyer=buyer_id, status=BuyerItem.HOLD).exclude(
        item__seller__pk=buyer_id).order_by('-view_time')

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = item.toDictionary()
        item_array.append(item_dict)

    response_data = {'status': 1, 'holding_pattern': item_array}
    return response_data


@time_method
def get_buyer_transactions(buyer_id):

    item_list = BuyerItem.objects.filter(
        buyer=buyer_id, status=BuyerItem.SOLD_TO).order_by('-view_time')

    item_array = []
    # get json representaion of item array
    for item in item_list:
        item_dict = item.toDictionary()
        item_array.append(item_dict)

    response_data = {'status': 1, 'buyer_history': item_array}
    return response_data

# -------------------------------------------- #
#             Helper Functions                 #
# -------------------------------------------- #
# Helper for uploading image to S3


def handle_file_s3(image_key, f):
    image_string = ""
    image_string = f

    conn = S3Connection(config['AWS_ACCESS_KEY'], config['AWS_SECRET_KEY'])
    # bucket = conn.create_bucket('com.bakkle.prod')
    bucket = conn.get_bucket(config['S3_BUCKET'])
    k = Key(bucket)
    image_key = config['S3_BUCKET'] + "_" + image_key
    k.key = image_key
    # http://boto.readthedocs.org/en/latest/s3_tut.html
    k.set_contents_from_string(image_string)
    k.set_acl('public-read')
    logging.debug(config['S3_URL'] + image_key)
    return config['S3_URL'] + image_key


def handle_delete_file_s3(image_path):
    file_parts = image_path.split("_")
    image_key = image_path.replace(config['S3_URL'], "")
    bucket_name = config['S3_BUCKET']
    if (len(file_parts) == 3):
        bucket_name = file_parts[0]
    conn = S3Connection(config['AWS_ACCESS_KEY'], config['AWS_SECRET_KEY'])
    # bucket = conn.create_bucket('com.bakkle.prod')
    bucket = conn.get_bucket(bucket_name)
    logging.debug(image_key)
    k = bucket.get_key(image_key)
    k.delete()

# Helper to handle image uploading


def imgupload(images, videos, seller_id):
    image_urls = ""
    # import pdb; pdb.set_trace()

    threads = []

    for i in images:
        # i = request.FILES['image']
        uhash = hex(random.getrandbits(128))[2:-1]
        image_key = "{}_{}.jpg".format(seller_id, uhash)
        filename = handle_file_s3(image_key, i['body'])
        if image_urls == "":
            image_urls = filename
        else:
            image_urls = image_urls + "," + filename
    for i in videos:
        # i = request.FILES['image']
        uhash = hex(random.getrandbits(128))[2:-1]
        image_key = "{}_{}.mp4".format(seller_id, uhash)
        filename = handle_file_s3(image_key, i['body'])
        if image_urls == "":
            image_urls = filename
        else:
            image_urls = image_urls + "," + filename
    return image_urls

# Helper for creating buyer items


def add_item_to_buyer_items(buyer_id, item_id, view_duration, status, message=None):

    try:
        view_duration = Decimal(view_duration)
    except ValueError:
        return {"status": 0, "error": "View Duration was not a valid decimal."}

    # get the item
    try:
        item = Items.objects.get(pk=item_id)
    except Items.DoesNotExist:
        item = None
        return {"status": 0, "error": "Item {} does not exist.".format(item_id)}

    # check if item already sold - if so, return an error:
    if(item.status == Items.SOLD):
        item = None
        return {"status": 0, "error": "Item has already been sold."}

    try:

        account = Account.objects.get(pk=buyer_id)
        # Create or update the buyer item

        if(account.pk == item.seller.pk):
            status = BuyerItem.MY_ITEM

        try:
            buyer_item = BuyerItem.objects.get(item=item.pk, buyer=buyer_id)
        except BuyerItem.DoesNotExist:

            buyer_item = BuyerItem.objects.create(
                buyer=account,
                item=item,
                status=status,
                confirmed_price=item.price,
                view_time=timezone.now(),
                view_duration=0)

        if (status == BuyerItem.SOLD):
            buyer_item.accepted_sale_price = buyer_item.confirmed_price
            item.status = Items.SOLD
            item.save()
        else:
            buyer_item.confirmed_price = item.price

        buyer_item.status = status
        buyer_item.view_duration = view_duration
        buyer_item.save()

    except Account.DoesNotExist:
        account = None
        response_data = {
            "status": 0, "error": "Account {} does not exist.".format(buyer_id)}
        return response_data

    response_data = {'status': 1}
    return response_data


# Helper for updating Item Statuses
def update_status(itemId, status):

    # Ensure that required fields are present otherwise send back a failed
    # status
    if (itemId is None or itemId == ""):
        response_data = {
            "status": 0, "error": "A required parameter was not provided."}
        return response_data

    # Get the item
    item = Items.objects.get(pk=itemId)
    item.status = status
    item.save()
    response_data = {"status": 1}
    return response_data


# Helper to return the delivery methods for items
def get_delivery_methods():
    response_data = {
        'status': 1, 'deliver_methods': (dict(Items.METHOD_CHOICES)).values()}
    return response_data

# -------------------------------------------- #
#               Testing Items                  #
# -------------------------------------------- #


# TODO: Remove eventually. Testing data.
@time_method
def reset(buyer_id):
    item_expire_time = 7  # days
    BuyerItem.objects.filter(buyer=buyer_id).delete()
    response_data = {"status": 1}
    return response_data
