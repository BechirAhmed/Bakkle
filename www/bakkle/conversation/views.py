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
from common import authenticate
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
        response_data = {"status":0, "error":"Buyer {} does not exist.".format(account_id)}
        return HttpResponse(json.dumps(response_data), content_type="application/json")



    convos = Conversation.objects.filter(buyer=account).filter(deleted_buyer = False)
    #convos_selling = Conversation.object.filter()
    


    response_data = {"status": 1}
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
    proposed_price = request.GET.get('proposed_price', "0.0")


    if (conversation_id == None or conversation_id == ""):
        response_data = { "status":0, "error": "A required parameter was not provided." }
        return HttpResponse(json.dumps(response_data), content_type="application/json")

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

    
    # Determine which person deleted the conversation
    buyer_id = message.conversation.buyer.id
    if str(account_id) == str(buyer_id) and message.buyer_seller_flag == False:
        message.viewed = datetime.datetime.now()
    elif str(account_id) != str(buyer_id) and message.buyer_seller_flag == True:
        message.viewed = datetime.datetime.now()

    message.save()

    response_data = {"status": 1}
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
        'start_date': convo.start_date,
        'deleted_seller': convo.deleted_seller,
        'deleted_buyer': convo.deleted_seller}

    return conversation_dict