from django.shortcuts import render

import json
from django.http import HttpResponse

from .models import Items

def index(request):
    #TODO: need to confirm order to display, chrono?, closest? "magic"?
    response_data = { 'now': 32, 'item-list': Items.objects.order_by('post_date')[:10] }
    print(response_data)
    return HttpResponse(json.dumps(response_data), content_type="application/json")

def detail(request):
    return HttpResponse("detail on item: {}".format(item_id))
