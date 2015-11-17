#!/usr/bin/python

# django settings must be called before importing models
import django
from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models


from tornado.log import logging
from common.apn import sendPushMessage
from random import randint

# Parms
use_sandbox = True
token_hex = '963c3f72abe5dee900f066e88486272dd7e2648948abb4352ecbb52294b7317e'
message = 'Test Payload'
sound = 'Bakkle_Notification_new.m4r'
badge = randint(1,9)

config = {}
if __name__ == "__main__":
   django.setup()
   config = { "apn_cert": "apn-push-prod.pem", "apn_key": "apn-push-prod.pem", "apn_sandbox": False }
   print("Running unit test for APN")
   sendPushMessage(None, token_hex, message, badge, sound, {})
