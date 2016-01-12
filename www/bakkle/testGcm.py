#!/usr/bin/python

# django settings must be called before importing models
import django
from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models


from tornado.log import logging
from common.gcmpush import sendGcmPushMessage
from random import randint

# Parms
registration_id = 'APA91bElw_W3qEvJeaIqFkifk9dp39SNegHZfZX4Rdw80pc6FQwco7eU9fPXfjLzqCUw-wX3SDvfvh24wATEwHHxbaSWzyRlGkE8Rx6OFHtCx464rMhZq6gd-WrqJoTL5djeg6cyjlDH'
message = 'Test Message'
sound = 'Bakkle_Notification_new.m4r'
badge = randint(1,9)

config = {}
if __name__ == "__main__":
   django.setup()
   print("Running unit test for GCM")
   sendGcmPushMessage(registration_id, message, badge, sound, {})
