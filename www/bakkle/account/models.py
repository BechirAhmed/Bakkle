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
cert_file = 'account/apn-push-prod-2015-03-30.p12.pem'
key_file  = 'account/apn-push-prod-2015-03-30.p12.pem'
if use_sandbox:
    cert_file = 'account/apn-push-dev-2015-03-30.p12.pem'
    key_file  = 'account/apn-push-dev-2015-03-30.p12.pem'


# Create your models here.
class Account(models.Model):
    email = models.CharField(max_length=200, unique = True)
    password = models.CharField(max_length=20)
    facebookId = models.CharField(max_length=200, unique = True)
    twitterId = models.CharField(max_length=200)
    displayName = models.CharField(max_length = 200)
    avatarImageUrl = models.CharField(max_length=200)
    sellerRating = models.DecimalField(max_digits = 2, decimal_places=1, null = True)
    itemsSold = models.IntegerField(default = 0)
    buyerRating = models.DecimalField(max_digits = 2, decimal_places=1, null = True)
    itemsBought = models.IntegerField(default = 0)
    maxDistance = models.IntegerField(default = 10)
    maxPrice = models.DecimalField(max_digits=7, decimal_places=2, default=100.00)
    displayNumItems = models.IntegerField(default = 100)
    def __str__(self):
        return "ID={} email={} displayname={}".format(self.id, self.email, self.displayName)

class Device(models.Model):
    account_id = models.ForeignKey(Account)
    dateAdded = models.DateTimeField(auto_now_add = True)
    lastSeenDate = models.DateTimeField(auto_now = True)
    apnsToken = models.CharField(max_length=64)
    ipAddress = models.CharField(max_length=15)
    uuid = models.CharField(max_length=36)
    notificationsEnabled = models.BooleanField(default = True)

    class Meta:
        unique_together = (("account_id", "uuid"))

    def send_notification(self, message, sound="default", badge=0):
        print(cert_file)
        apns = APNs(True, cert_file=cert_file, key_file=key_file)
        payload = Payload(alert='bob', sound='default', badge='0')
        dt = self.apnsToken.replace(' ', '').replace('<', '').replace('>', '')
        print("notifying {} token {}".format(self.account_id, dt))
        apns.gateway_server.send_notification(dt, payload)
        #TODO: Log this to db so we know what we did.
