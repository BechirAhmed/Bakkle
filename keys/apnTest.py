#!/usr/bin/python

import time
from apns import APNs, Payload

# Parms
use_sandbox = True
use_sandbox = False
token_hex = '1938ee016dae5b93ffe00015dabf7231ff628f41750a38c70361c33458df2d68' # black iphone 5 (Sandor)
message = 'Test Payload'
soundname = 'Bakkle_Notification_new.m4r'
badge = 1

# Config
cert_file = 'Certificates.p12.pem'
key_file = 'Certificates.p12.pem'


apns = APNs(use_sandbox=use_sandbox, cert_file=cert_file, key_file=key_file)

test = 2
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
