#!/usr/bin/python

import time
from apns import APNs, Payload

# Parms
token_hex = '963c3f72abe5dee900f066e88486272dd7e2648948abb4352ecbb52294b7317e'
message = 'Test Payload'
soundname = 'Bakkle_Notification_new.m4r'
badge = 1

# Config
use_sandbox=False
cert_file = 'apn-push-prod.pem'
key_file = cert_file


apns = APNs(use_sandbox=use_sandbox, cert_file=cert_file, key_file=key_file)

test = 1
if test == 0:
    custom_dict = {}
if test == 1:
    custom_dict = {'item_id': 42, 'title': 'Orange Mower'}
    message = custom_dict['title']
    custom = {'item_id': 42}
if test == 2:
    custom_dict = {
        'chat_id': 69, 'item_id': 10, 'message': 'I want to buy your mower', 'name': 'Hugo Chavez'}
    message = custom_dict['message']
#custom = {
#    'chat_id': 69, 'item_id': 2542 , 'seller_id': 9, 'buyer_id': 13}
custom = {
    'chat_id': 3284, 'item_id': 2056 , 'seller_id': 3, 'buyer_id': 9}

# Send a notification
#payload = Payload(alert=message, sound=soundname, badge=badge)
payload = Payload(alert=message, sound=soundname, badge=badge, custom=custom)
print apns.gateway_server.send_notification(token_hex, payload)

# Send multiple notifications in a single transmission
#frame = Frame()
#identifier = 1
#expiry = time.time()+3600
#priority = 10
#frame.add_item(token_hex, payload, identifier, expiry, priority)
# apns.gateway_server.send_notification_multiple(frame)
