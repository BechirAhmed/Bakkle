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
    conversation = get_object_or_404(Conversation, pk=conversation_id)
    context = {
        'convo': conversation,
    }
    return render(request, 'conversation/detail.html', context)

#--------------------------------------------#
#           Conversation Methods             #
#--------------------------------------------#
