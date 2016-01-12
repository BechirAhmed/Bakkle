from django.shortcuts import render

import datetime
import json
import md5
import logging

from django.http import HttpResponse, HttpResponseRedirect, Http404, HttpResponseForbidden
from django.core.urlresolvers import reverse
from django.template import RequestContext, loader
from django.utils import timezone
from django.shortcuts import get_object_or_404
from django.views.decorators.http import require_POST
from django.db.models import Q
from decimal import *

from .models import Account, Device
from items.models import Items, BuyerItem
from common.decorators import authenticate
from common.decorators import time_method

# Show a list of all accounts in the system.


@time_method
def index():
    account_list = Account.objects.all()

    return account_list

# Show detail on an account


@time_method
def detail(account_id):
    account = get_object_or_404(Account, pk=account_id)
    devices = Device.objects.filter(account_id=account_id)
    buyer_items = BuyerItem.objects.filter(buyer=account_id)
    items_viewed = buyer_items.count()
    seller_items = Items.objects.filter(seller=account_id)
    total_items = seller_items.count()
    items_sold = Items.objects.filter(seller=account_id,
                                      status=Items.SOLD).count()
    context = {
        'account': account,
        'devices': devices,
        'items': buyer_items,
        'selling': seller_items,
        'item_count': total_items,
        'items_sold': items_sold,
        'items_viewed': items_viewed
    }
    return context

# Method for reseting account feed (only for detail page)


@time_method
def reset(account_id):
    BuyerItem.objects.filter(buyer=account_id).delete()

    return detail(account_id)

# Show dashboard


@time_method
def dashboard():
    registered_users = Account.objects.count()
    active_users = Account.objects.filter(disabled=False).count()
    total_items = Items.objects.count()
    total_sold = Items.objects.filter(status=Items.SOLD).count()
    total_expired = Items.objects.filter(status=Items.EXPIRED).count()
    total_spam = Items.objects.filter(status=Items.SPAM).count()
    total_deleted = Items.objects.filter(status=Items.DELETED).count()
    total_pending = Items.objects.filter(status=Items.PENDING).count()

    context = {
        'register_users': registered_users,
        'active_users': active_users,
        'total_items': total_items,
        'total_sold': total_sold,
        'total_expired': total_expired,
        'total_deleted': total_deleted,
        'total_spam': total_spam,
        'total_pending': total_pending
    }
    return context


@time_method
def device_detail(device_id):
    try:
        device = Device.objects.get(pk=device_id)
    except Device.DoesNotExist:
        return None

    return device


@time_method
def device_notify(device_id):
    try:
        device = Device.objects.get(pk=device_id)
    except Device.DoesNotExist:
        device = None
        response_data = {
            "status": 0,
            "error": "Device {} does not exist.".format(device_id)}
        return response_data

    if (device.is_ios):
        device.send_notification("Test: New Item", "0", "default", {
                                 'item_id': 42,
                                 'title': 'Apple mouse with scroll wheel'})
        device.send_notification("Test: New Chat Image", "1", "default", {
                                 'conversation_id': 25,
                                 'message': 'Buyer/Seller sent new picture',
                                 'image':
                                 'https://app.bakkle.com/img/b8348df.jpg',
                                 'name': 'Taro Finnick'})
        device.send_notification("Test: New Chat", "2", "default", {
                                 'conversation_id': 24,
                                 'message': 'I want to buy your mower',
                                 'name': 'Konger Smith'})
        device.send_notification("Test: New Offer", "3", "default", {
                                 'conversation_id': 24,
                                 'message':
                                 'New offer received, $12.22 for Orange Mower',
                                 'proposed_price': 12.22,
                                 'name': 'Konger Smith'})

    response_data = {"status": 1}
    return response_data


@time_method
def device_notify_all(account_id):
    # Get all devices for the account
    devices = Device.objects.filter(account_id=account_id, is_ios=True)

    # notify each device
    for device in devices:
        device_notify(device.id)

    response_data = {"status": 1}
    return response_data


@time_method
def settings():
    response_data = {"status": 1, "settings_dict":
                     {"image_width": 660, "image_height": 660,
                      "image_quality": 0.2, "feed_items_to_load": 20,
                      "image_precache": 10, "video_length_sec": 15.0}}
    return response_data


@time_method
def set_description(account_id, description):
    try:
        account = Account.objects.get(pk=account_id)
    except Account.DoesNotExist:
        return {"status": 0, "message": "Invalid account id"}
    account.description = description
    account.save()
    return {"status": 1, "account": account.toDictionary()}


@time_method
def get_account(accountId):
    try:
        account = Account.objects.get(pk=accountId)
    except Account.DoesNotExist:
        return {"status": 0, "message": "Invalid account id"}
    return {"status": 1, "account": account.toDictionary()}


@time_method
def login_facebook(facebook_id, device_uuid, user_location, app_version, is_ios, client_ip, app_flavor):

    location = ""
    try:
        positions = user_location.split(",")
        if len(positions) < 2:
            response_data = {
                "status": 0, "error": "User location was not in the correct format."}
            return response_data
        else:
            TWOPLACES = Decimal(10) ** -2
            lat = Decimal(positions[0]).quantize(TWOPLACES)
            lon = Decimal(positions[1]).quantize(TWOPLACES)
            location = str(lat) + "," + str(lon)
    except ValueError:
        response_data = {
            "status": 0, "error": "Latitude or Longitude was not a valid decimal."}
        return response_data

    # Get the account for that facebook ID and it's associated device
    try:
        account = Account.objects.get(
            facebook_id=facebook_id, app_flavor=app_flavor)
    except Account.DoesNotExist:
        account = None
        response_data = {
            "status": 0, "error": "Account {} does not exist.".format(facebook_id)}
        return response_data

    # Update account location
    account.user_location = location
    account.save()

    # register the device
    device = device_register(
        client_ip, device_uuid, account, location, app_version)

    # Create authentication token
    login_date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Set authentication token and save it
    device.auth_token = md5.new(login_date).hexdigest() + "_" + str(account.id)
    if(is_ios.lower() == "true"):
        device.is_ios = True
    else:
        device.is_ios = False
    device.save()

    return {"status": 1, "auth_token": device.auth_token,
            "display_name": account.display_name }

# Logout of account


@time_method
def logout(auth_token, device_uuid, client_ip):

    # Check that all require params are sent and are of the right format
    if (auth_token == None or auth_token.strip() == "" or auth_token.find('_') == -1) or (device_uuid == None or device_uuid.strip() == ""):
        response_data = {
            "status": 0, "error": "A required parameter was not provided."}
        return response_data

    # get the account id and the device the user is logging in from
    account_id = auth_token.split('_')[1]
    try:
        account = Account.objects.get(pk=account_id)
    except Account.DoesNotExist:
        account = None
        response_data = {
            "status": 0, "error": "Account {} does not exist.".format(account_id)}
        return response_data

    # Get the device and update its fields. Also empty the auth_token
    try:
        device = Device.objects.get(uuid=device_uuid, account_id=account)
    except Device.DoesNotExist:
        device = None
        response_data = {"status": 0, "error": "Device {} does not exist for account {}.".format(
            device_uuid, account_id)}
        return response_data

    device.last_seen_date = datetime.datetime.now()
    device.ip_address = client_ip
    device.auth_token = ""
    device.save()

    return {"status": 1}

# Register with Facebook

bkAccountTypeGuest    = 0
bkAccountTypeFacebook = 2
bkAccountTypeEmail    = 3
@time_method
def facebook(facebook_id, display_name, device_uuid, avatar_image_url, app_flavor, account_type):

    # check for existing local account
    try:
        if int(account_type) == bkAccountTypeEmail:
            obj = Account.objects.get(facebook_id=facebook_id, app_flavor=app_flavor)
            # Already exists, throw error
            return { "status": 0, "message": "account already exists" }
    except Account.DoesNotExist:
        # we have no object!  do something
        pass

    # Update or create the account
    account = Account.objects.get_or_create(
        facebook_id=facebook_id,
        app_flavor=app_flavor,
        defaults={'display_name': display_name})[0]
    account.display_name = display_name
    account.avatar_image_url = avatar_image_url
    account.save()
    return {"status": 1}

# Get guest user_id
@time_method
def guest_user_id(device_uuid):
    return { "status": 1, "userid": md5.new(device_uuid).hexdigest() }

# Get local user_id
@time_method
def local_user_id(email, device_uuid):
    return { "status": 1, "userid": md5.new(email).hexdigest() }

# Set name and profile info
@time_method
def update_profile(facebook_id, display_name, device_uuid, app_flavor):
    # Update or create the account
    try:
        account = Account.objects.get_or_create(
            facebook_id=facebook_id,
            app_flavor=app_flavor)[0]
        account.display_name = display_name
        account.save()
    except:
        return {"status": 0, "message": "error updating profile"}
    return {"status": 1}

# Set name and profile info
@time_method
def set_password(facebook_id, device_uuid, app_flavor, password):

    try:
        account = Account.objects.get_or_create(
            facebook_id=facebook_id,
            app_flavor=app_flavor)[0]
        account.password = password
        account.save()
        #logging.info("password set account.id={}".format(account.id))
    except:
        return {"status": 0, "message": "error setting password"}
    return {"status": 1}

# Set name and profile info
@time_method
def authenticate_local(facebook_id, device_uuid, app_flavor, password):

    try:
        account = Account.objects.get_or_create(
            facebook_id=facebook_id,
            app_flavor=app_flavor)[0]
        if md5.new(account.password).hexdigest() != md5.new(password).hexdigest():
            #logging.info("authentication rejected account.id={}".format(account.id))
            return {"status": 0, "message": "incorrect username or password"}
    except:
        #logging.info("authentication failed account.id={}".format(facebook_id))
        return {"status": 0, "message": "incorrect username"}
    #logging.info("authentication succeeded account.id={}".format(account.id))
    return {"status": 1}



# DEVICE STUFF

# Register a new device


def device_register(ip, uuid, user, location, app_version):
    device = Device.objects.get_or_create(
        uuid=uuid,
        account_id=user,
        defaults={'notifications_enabled': True, })[0]
    device.last_seen_date = datetime.datetime.now()
    device.ip_address = ip
    device.user_location = location
    device.app_version = int(float(app_version))
    device.save()
    return device

# Register a new device for notifications


@time_method
def device_register_push(account_id, device_uuid, device_token, device_type, client_ip):
    logging.info("register_push")
    prevDevices = Device.objects.filter(Q(uuid=device_uuid) | Q(apns_token=device_token))

    for device in prevDevices:
        device.apns_token = ""
        device.save()

    try:
        account = Account.objects.get(pk=account_id)
    except Account.DoesNotExist:
        account = None
        response_data = {
            "status": 0, "error": "Account {} does not exist.".format(account_id)}
        return response_data

    # Either get the device or create it if it is a new one
    device = Device.objects.get_or_create(
        uuid=device_uuid,
        account_id=account,
        defaults={'notifications_enabled': True, })[0]
    device.last_seen_date = datetime.datetime.now()
    device.ip_address = client_ip
    device.apns_token = device_token
    device.device_token = device_type
    device.save()
    logging.info("registered {} type={}".format(device_token, device_type))

    response_data = {"status": 1}
    return response_data

# """ Notify all devices of a new item """
# @csrf_exempt
# @time_method
# def device_notify_all_new_item(request):
# Get all devices
#     message = request.POST.get('message', request.GET.get('message', ""))
#     if message == None or message == "":
#         response_data = { "status": 0, "error": "No message supplied" }
#         return response_data

# devices = Device.objects.filter(is_ios=True) #todo: add active filter,
# add subscribed to notifications filter.

# notify each device
#     for device in devices:
# lookup number of unread messages
# badge = "0" #TODO: count number of unread messages
#         device.send_notification(message, badge, "")

#     response_data = { "status": 1 }
#     return response_data

# Dispatch a notification to device
# @csrf_exempt
# @time_method
# def device_notify(request, device_id):
#     """
#     Example new-item:
#        device.send_notification("New $12.22 - Apple mouse with scroll wheel", "default", num_conversations_with_new_messages, "",
#        {'item_id': 42, 'title': 'Apple mouse with scroll wheel'} )

#     Example new-offer:
#        device.send_notification("New offer received, $12.22, for Orange Mower", "default", num_conversations_with_new_messages, "",
#        {'chat_id': 23, 'message': 'New offer received, $12.22, for Orange Mower', 'offer': 12.22, 'name': 'Konger Smith'} )

#     Example new-chat-message:
#        device.send_notification("I want to buy your mower.", "default", num_conversations_with_new_messages, "",
#        {'chat_id': 24, 'message': 'I want to buy your mower', 'offer': 12.22, 'name': 'Konger Smith'} )

#     Example new-chat-image:
#        device.send_notification("Buyer/Seller sent new picture", "default", num_conversations_with_new_messages, "",
#        {'chat_id': 25, 'message': 'Buyer/Seller sent new picture', 'image': image_url, 'name': 'Taro Finnick'} )

#     """
#     try:
#         device = Device.objects.get(pk=device_id)
#     except Device.DoesNotExist:
#         device = None
#         response_data = {"status":0, "error":"Device {} does not exist.".format(device_id)}
#         return response_data

#     if (device.is_ios):
#         device.send_notification("Test: New Item", "0", "default", {'item_id': 42, 'title': 'Apple mouse with scroll wheel'})
#         device.send_notification("Test: New Chat Image", "1", "default", {'conversation_id': 25, 'message': 'Buyer/Seller sent new picture', 'image': 'https://app.bakkle.com/img/b8348df.jpg', 'name': 'Taro Finnick'})
#         device.send_notification("Test: New Chat", "2", "default", {'conversation_id': 24, 'message': 'I want to buy your mower', 'name': 'Konger Smith'})
#         device.send_notification("Test: New Offer", "3", "default", {'conversation_id': 24, 'message': 'New offer received, $12.22, for Orange Mower', 'proposed_price': 12.22, 'name': 'Konger Smith'})
#     response_data = { "status": 1 }
#     return response_data

# Dispatch a notification to all devices for that user
# @csrf_exempt
# @time_method
# def device_notify_all(request, account_id):
# Get all devices for the account
#     devices = Device.objects.filter(account_id=account_id,is_ios=True)

# notify each device
#     for device in devices:
#         device_notify(request, device.id)

#     response_data = { "status":1 }
#     return response_data

# Get's the client IP from a request
# @time_method
# def get_client_ip(request):
#     x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
#     if x_forwarded_for:
#         ip = x_forwarded_for.split(',')[0]
#     else:
#         ip = request.META.get('REMOTE_ADDR')
#     return ip
