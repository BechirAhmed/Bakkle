#!/usr/bin/python

import time
from apns import APNs, Frame, Payload

# Parms
use_sandbox=True
token_hex = 'e69ffa8cb3299d2c3428641d4213be48ce37d373554ab18ce905dd2eab7c7655'
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

# Send a notification
payload = Payload(alert=message, sound=soundname, badge=badge)
apns.gateway_server.send_notification(token_hex, payload)

# Send multiple notifications in a single transmission
#frame = Frame()
#identifier = 1
#expiry = time.time()+3600
#priority = 10
#frame.add_item(token_hex, payload, identifier, expiry, priority)
#apns.gateway_server.send_notification_multiple(frame)
