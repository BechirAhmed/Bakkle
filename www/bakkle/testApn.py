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
token_hex = '1938ee016dae5b93ffe00015dabf7231ff628f41750a38c70361c33458df2d68'
message = 'Test Payload'
sound = 'Bakkle_Notification_new.m4r'
badge = randint(1,9)

config = {}
if __name__ == "__main__":
   django.setup()
   config = { "apn_cert": "apn-push-prod.pem", "apn_key": "apn-push-prod.pem", "apn_sandbox": False }
   print("Running unit test for APN")
   sendPushMessage(None, token_hex, message, badge, sound, {}, True)
