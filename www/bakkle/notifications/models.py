from django.db import models

import time
from apns import APNs, Frame, Payload


# Parms
use_sandbox=True
token_hex = 'e69ffa8cb3299d2c3428641d4213be48ce37d373554ab18ce905dd2eab7c7655'
message = 'Test Payload'
soundname = 'default'
badge = 1

# Config
cert_file = 'notifications/apn-push-prod-2015-03-30.p12.pem'
key_file  = 'notifications/apn-push-prod-2015-03-30.p12.pem'
if use_sandbox:
   cert_file = 'notifications/apn-push-dev-2015-03-30.p12.pem'
   key_file  = 'notifications/apn-push-dev-2015-03-30.p12.pem'


class PushRegistrations(models.Model):
    user_id = models.CharField(max_length=200)
    device_token = models.CharField(max_length=200)
    subscribe_date = models.DateTimeField('date subscribed')
    enabled = models.IntegerField(default=1)
    def __str__(self):
        return "User: {id}".format(id=self.user_id)

    def isActive(self):
        return self.enabled==1

    def send_notification(self, message, sound="default", badge=0):
        print(cert_file)
        apns = APNs(True, cert_file=cert_file, key_file=key_file)
        payload = Payload(alert='bob', sound='default', badge='0')
        dt = self.device_token.replace(' ', '').replace('<', '').replace('>', '')
        print("notifying {} token {}".format(self.user_id, dt))
        apns.gateway_server.send_notification(dt, payload)
        #TODO: Log this to db so we know what we did.

