#!/usr/bin/python

# django settings must be called before importing models
import django
from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models
from account.models import Account, Device

from tornado.log import logging
from common.gcm import sendGcmPushMessage
from random import randint

# Parms
device_id = 2
message = 'Test Message'
sound = 'Bakkle_Notification_new.m4r'
badge = randint(1,9)
custom = {}

if __name__ == "__main__":
    try:
        device = Device.objects.get(pk=device_id)
        print("Notifying {}".format(device.account_id.display_name))
        device.send_notification(message=message, badge=badge, sound=sound, custom=custom)
    except Device.DoesNotExist:
        print("Device does not exist")
