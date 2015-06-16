#!/usr/bin/python

import time
from apns import APNs, Frame, Payload

# Parms
use_sandbox=True
token_hex = 'e69ffa8cb3299d2c3428641d4213be48ce37d373554ab18ce905dd2eab7c7655'
token_hex = '3c28f1cc5c714aa05f959ccd7def34a87df4dabc46979c0a58741cba362a83b0'
message = 'Test Payload'
soundname = 'default'
badge = 1

# Config
cert_file = 'apn-push-prod-2015-03-30.p12.pem'
key_file  = 'apn-push-prod-2015-03-30.p12.pem'
if use_sandbox:
   cert_file = 'apn-push-dev-2015-03-30.p12.pem'
   key_file  = 'apn-push-dev-2015-03-30.p12.pem'


apns = APNs(use_sandbox=use_sandbox, cert_file=cert_file, key_file=key_file)

test=2
if test==0:
	custom_dict = {}
if test==1:
	custom_dict = {'item_id': 42, 'title': 'Orange Mower' }
	message = custom_dict['title']
if test==2:
	custom_dict = {'chat_id': 69, 'message': 'I want to buy your mower', 'name': 'Hugo Chavez' }
	message = custom_dict['message']

# Send a notification
payload = Payload(alert=message, sound=soundname, badge=badge)
#payload = Payload(alert=message, sound=soundname, badge=badge, custom=custom_dict)
print apns.gateway_server.send_notification(token_hex, payload)

# Send multiple notifications in a single transmission
#frame = Frame()
#identifier = 1
#expiry = time.time()+3600
#priority = 10
#frame.add_item(token_hex, payload, identifier, expiry, priority)
#apns.gateway_server.send_notification_multiple(frame)
