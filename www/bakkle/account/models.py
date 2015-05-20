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
    facebook_id = models.CharField(max_length=200, unique = True)
    twitter_id = models.CharField(max_length=200)
    display_name = models.CharField(max_length = 200)
    avatar_image_url = models.CharField(max_length=200)
    seller_rating = models.DecimalField(max_digits = 2, decimal_places=1, null = True)
    items_sold = models.IntegerField(default = 0)
    buyer_rating = models.DecimalField(max_digits = 2, decimal_places=1, null = True)
    items_bought = models.IntegerField(default = 0)
    max_distance = models.IntegerField(default = 10)
    max_price = models.DecimalField(max_digits=7, decimal_places=2, default=100.00)
    display_num_items = models.IntegerField(default = 100)
    user_location = models.CharField(max_length=15, null = True)
    disabled = models.BooleanField(default = False)

    def __str__(self):
        return "ID={} email={} displayname={}".format(self.id, self.email, self.display_name)

class Device(models.Model):
    account_id = models.ForeignKey(Account)
    date_added = models.DateTimeField(auto_now_add = True)
    last_seen_date = models.DateTimeField(auto_now = True)
    apns_token = models.CharField(max_length=64)
    ip_address = models.CharField(max_length=15)
    uuid = models.CharField(max_length=36)
    notifications_enabled = models.BooleanField(default = True)
    auth_token = models.CharField(max_length = 256, default = "")
    user_location = models.CharField(max_length=15, null = True)
    app_version = models.IntegerField(default=1)

    class Meta:
        unique_together = ("account_id", "uuid")

    """
    Example new-item:
       device.send_notification("New $12.22 - Apple mouse with scroll wheel", "default", num_conversations_with_new_messages, "",
       {'item_id': 42, 'title': 'Apple mouse with scroll wheel'} )

    Example new-offer:
       device.send_notification("New offer received, $12.22, for Orange Mower", "default", num_conversations_with_new_messages, "",
       {'chat_id': 23, 'message': 'New offer received, $12.22, for Orange Mower', 'offer': 12.22, 'name': 'Konger Smith'} )

    Example new-chat-message:
       device.send_notification("I want to buy your mower.", "default", num_conversations_with_new_messages, "",
       {'chat_id': 24, 'message': 'I want to buy your mower', 'offer': 12.22, 'name': 'Konger Smith'} )

    Example new-chat-image:
       device.send_notification("Buyer/Seller sent new picture", "default", num_conversations_with_new_messages, "",
       {'chat_id': 25, 'message': 'Buyer/Seller sent new picture', 'image': image_url, 'name': 'Taro Finnick'} )

    """
    def send_notification(self, message="", badge=0, sound="", custom={}):
        print(cert_file)
        apns = APNs(True, cert_file=cert_file, key_file=key_file)
        payload = Payload(alert=message, badge=badge, sound=sound, custom=custom, category="bakkleNotification")
        dt = self.apns_token.replace(' ', '').replace('<', '').replace('>', '')
        print("notifying {} token {}".format(self.account_id, dt))
        apns.gateway_server.send_notification(dt, payload)
        #TODO: Log this to db so we know what we did.


