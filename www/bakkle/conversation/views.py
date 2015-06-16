from django.shortcuts import render

import json
import datetime
import os

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

from items.models import Items, BuyerItem
from account.models import Account, Device
from .models import Conversation, Message
from common import authenticate,get_number_conversations_with_new_messages
from items.views import imgupload, get_item_dictionary, get_account_dictionary
from django.conf import settings

#--------------------------------------------#
#               Web page requests            #
#--------------------------------------------#
@csrf_exempt
def index(request):
    # List all items (this is for web viewing of data only)
    conversation_list = Conversation.objects.all()
    context = {
        'conversation_list': conversation_list,
    }
    return render(request, 'conversation/index.html', context) 

@csrf_exempt
def detail(request, conversation_id):
    # get the item with the item id (this is for web viewing of data only)
    convo = get_object_or_404(Conversation, pk=conversation_id)
    messages = Message.objects.filter(conversation=convo)
    message_count = messages.count()
    context = {
        'convo': convo,
        'messages': messages,
        'message_count': message_count
    }
    return render(request, 'conversation/detail.html', context)

#--------------------------------------------#
#           Conversation Methods             #
#--------------------------------------------#
@csrf_exempt
@require_POST
@authenticate
def delete_conversation(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    account_id = auth_token.split('_')[1]
    
    conversation_id = request.POST.get('conversation_id', "")

    if (conversation_id == None or conversation_id == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    try: 
        convo = Conversation.objects.get(pk=conversation_id)
    except Conversation.DoesNotExist:
        convo = None
        response_data = {"status":0, "error":"Conversation {} does not exist.".format(conversation_id)}
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # Determine which person deleted the conversation
    buyer_id = convo.buyer.id
    if str(account_id) == str(buyer_id):
        convo.deleted_buyer = True
    else:
        convo.deleted_seller = True

    convo.save();

    # Delete all messages to this point for that person
    messages = Message.objects.filter(conversation = convo)
    for message in messages:
        if str(account_id) == str(buyer_id):
            message.deleted_buyer = True
        else:
            message.deleted_seller = True
        message.save()

    response_data = {"status": 1}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def get_conversations(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    account_id = auth_token.split('_')[1]

    try:
        account = Account.objects.get(pk=account_id)
    except Account.DoesNotExist:
        account = None
        response_data = {"status":0, "error":"Account {} does not exist.".format(account_id)}
        return HttpResponse(json.dumps(response_data), content_type="application/json")


    items_selling = Items.objects.filter(seller=account).exclude(status = Items.DELETED)
    convos = Conversation.objects.filter(Q(buyer=account,deleted_buyer = False) | Q(item__in=items_selling, deleted_seller=False))
    #convos_selling = Conversation.object.filter()
    
    convo_array = []
    for convo in convos:
        convo_dict = get_conversation_dictionary(convo)
        convo_array.append(convo_dict)

    response_data = {"status": 1, "conversations": convo_array}
    return HttpResponse(json.dumps(response_data), content_type="application/json")


#--------------------------------------------#
#              Message Methods               #
#--------------------------------------------#

@csrf_exempt
@require_POST
@authenticate
def send_message(request):
    # Get the authentication code
    auth_token = request.GET.get('auth_token')
    account_id = auth_token.split('_')[1]
    
    conversation_id = request.GET.get('conversation_id', "")
    message_text = request.GET.get('message', "")
    proposed_price = request.GET.get('proposed_price', None)

    devices = Device.objects.all()
    for device in devices:
        content = {}
        print("sending to ")
        device.send_notification(message_text, "0", "default", content)

    if (conversation_id == None or conversation_id == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    if (proposed_price != None):
        try:
            proposed_price = Decimal(proposed_price)
        except ValueError:
            response_data = { "status":0, "error": "Proposed Price was not a valid decimal." }
            return HttpResponse(json.dumps(response_data), content_type="application/json")

    try: 
        convo = Conversation.objects.get(pk=conversation_id)
    except Conversation.DoesNotExist:
        convo = None
        response_data = {"status":0, "error":"Conversation {} does not exist.".format(conversation_id)}
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    # update the conversation so neither person has it deleted
    convo.deleted_seller = False
    convo.deleted_buyer = False
    convo.save()

    # Determine which person is sending the message
    buyer_id = convo.buyer.id
    buyer_flag = False
    if str(account_id) == str(buyer_id):
        buyer_flag = True

    image_url = ""
    if 'image' in request.FILES:
        # Check for the image params. The max number is 5 and is defined in settings
        image_url = imgupload(request, account_id)

    message = Message.objects.create(
            conversation = convo,
            message = message_text,
            proposed_price = proposed_price,
            url= image_url,
            buyer_seller_flag = buyer_flag)
    message.save()


    """
    Example new-offer:
       device.send_notification("New offer received, $12.22, for Orange Mower", "default", num_conversations_with_new_messages, "",
       {'chat_id': 23, 'message': 'New offer received, $12.22, for Orange Mower', 'offer': 12.22, 'name': 'Konger Smith'} )

    Example new-chat-message:
       device.send_notification("I want to buy your mower.", "default", num_conversations_with_new_messages, "",
       {'chat_id': 24, 'message': 'I want to buy your mower', 'offer': 12.22, 'name': 'Konger Smith'} )

    Example new-chat-image:
       device.send_notification("Buyer/Seller sent new picture", "default", num_conversations_with_new_messages, "",
       {'chat_id': 25, 'message': 'Buyer/Seller sent new picture', 'image': image_url, 'name': 'Taro Finnick'} )

    """
    # Try to notify the other person
    if(buyer_flag):
        notify_id = convo.item.seller.id
    else:
        notify_id = convo.buyer.id

    device = Device.objects.filter(Q(account_id = notify_id) & ~Q(auth_token="")).order_by('-last_seen_date')
    if device.count() > 0:
        send_to_device = device[0]

        name = ""
        if buyer_flag:
            name = convo.item.seller.display_name
        else:
            name = convo.buyer.display_name

        content = {"conversation_id":convo.id, "name":name}

        text = ""        
        if message.proposed_price != None:
            text = "New offer received, ${}, for {}".format(message.proposed_price, convo.item.title)
            content["proposed_price"] = message.proposed_price
        elif image_url != "":
            text = "{} sent a new picture for {}".format(name, convo.item.title)
            content["image"] = message.url
        else:
            text = message.message
        content["message"] = text
        badge = get_number_conversations_with_new_messages(notify_id)
        send_to_device.send_notification(text, badge, "default", content)

    response_data = {"status": 1}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def delete_message(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    account_id = auth_token.split('_')[1]
    
    message_id = request.POST.get('message_id', "")


    if (message_id == None or message_id == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    try: 
        message = Message.objects.get(pk=message_id)
    except Message.DoesNotExist:
        message = None
        response_data = {"status":0, "error":"Message {} does not exist.".format(message_id)}
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    
    # Determine which person deleted the conversation
    buyer_id = message.conversation.buyer.id
    if str(account_id) == str(buyer_id):
        message.deleted_buyer = True
    else:
        message.deleted_seller = True

    message.save()

    response_data = {"status": 1}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def view_message(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    account_id = auth_token.split('_')[1]
    
    message_id = request.POST.get('message_id', "")


    if (message_id == None or message_id == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    try: 
        message = Message.objects.get(pk=message_id)
    except Message.DoesNotExist:
        message = None
        response_data = {"status":0, "error":"Message {} does not exist.".format(message_id)}
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    
    # Determine which person viewed the conversation
    buyer_id = message.conversation.buyer.id
    if str(account_id) == str(buyer_id) and message.buyer_seller_flag == False:
        message.viewed = datetime.datetime.now()
    elif str(account_id) != str(buyer_id) and message.buyer_seller_flag == True:
        message.viewed = datetime.datetime.now()

    message.save()

    response_data = {"status": 1}
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
@require_POST
@authenticate
def get_messages(request):
    # Get the authentication code
    auth_token = request.POST.get('auth_token')
    account_id = auth_token.split('_')[1]
    
    conversation_id = request.POST.get('conversation_id', "")

    if (conversation_id == None or conversation_id == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    try: 
        convo = Conversation.objects.get(pk=conversation_id)
    except Conversation.DoesNotExist:
        convo = None
        response_data = {"status":0, "error":"Conversation {} does not exist.".format(conversation_id)}
        return HttpResponse(json.dumps(response_data), content_type="application/json")

    buyer_id = convo.buyer.id
    user_is_buyer = False
    if str(account_id) == str(buyer_id):
        user_is_buyer = True
    

    if(user_is_buyer):
        messages = Message.objects.filter(conversation=convo, deleted_buyer = False)
    else:
        messages = Message.objects.filter(conversation=convo, deleted_seller = False)

    message_array = []
    for message in messages:
        message_dict = get_message_dictionary(message, user_is_buyer)
        message_array.append(message_dict)

    response_data = {"status": 1, "messages": message_array}
    return HttpResponse(json.dumps(response_data), content_type="application/json")


#--------------------------------------------#
#             Helper Functions               #
#--------------------------------------------#
# Helper for making an Item into a dictionary for JSON
def get_conversation_dictionary(convo):
   
    buyer_dict = get_account_dictionary(convo.buyer)
    item_dict = get_item_dictionary(convo.item)

    conversation_dict = {'pk': convo.id,
        'buyer': buyer_dict,
        'item': item_dict,
        'start_date': convo.start_date.strftime("%Y-%m-%d %H:%M:%S"),
        'deleted_seller': convo.deleted_seller,
        'deleted_buyer': convo.deleted_seller}

    return conversation_dict

def get_message_dictionary(message, user_is_buyer):
    sent_by_user = False
    if(user_is_buyer and message.buyer_seller_flag):
        sent_by_user = True
    elif (not user_is_buyer and not message.buyer_seller_flag):
        sent_by_user = True

    viewed = ""
    if(message.viewed != None):
        viewed = message.viewed.strftime("%Y-%m-%d %H:%M:%S")

    proposed_price = ""
    if(message.proposed_price != None):
        proposed_price = str(message.proposed_price)

    message_dict = {'pk': message.id,
        'sent_by_user': sent_by_user,
        'date_sent': message.date_sent.strftime("%Y-%m-%d %H:%M:%S"),
        'viewed': viewed,
        'message': message.message,
        'url': message.url,
        'proposed_price': proposed_price,
        'deleted_seller': message.deleted_seller,
        'deleted_buyer': message.deleted_buyer }

    return message_dict
