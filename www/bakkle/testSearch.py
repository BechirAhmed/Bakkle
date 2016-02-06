#!/usr/bin/python

import sys

# django settings must be called before importing models
import django
from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models


from tornado.log import logging
from random import randint

from items.itemsCommonHandlers import feed


# Parms
search_text = ""
buyer_id=4
device_uuid="A34C43E2-D574-4692-B7D3-6862BF0C8B6E"
user_location="39.1706609513591, -86.514961100786"
filter_distance=100
filter_price=100

if len(sys.argv) > 1:
   search_text = sys.argv[1]


params = {
   "buyer_id":buyer_id,
   "device_uuid":device_uuid,
   "user_location":user_location,
   "search_text":search_text,
   "filter_distance":filter_distance,
   "filter_price":filter_price
}

if __name__ == "__main__":
   django.setup()
   print("Running unit test for SEARCH")
   print("parms={}".format(params))
   print feed(buyer_id, device_uuid, user_location, search_text, filter_distance, filter_price)
