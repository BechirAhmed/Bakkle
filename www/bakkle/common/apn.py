#!/usr/bin/python

import time
from apns import APNs, Payload
from common.decorators import run_async

# Parms
use_sandbox = True
token_hex = 'e69ffa8cb3299d2c3428641d4213be48ce37d373554ab18ce905dd2eab7c7655'
# token_hex =
# '3c28f1cc5c714aa05f959ccd7def34a87df4dabc46979c0a58741cba362a83b0'
message = 'Test Payload'
soundname = 'chord.m4r'
badge = 1

# Config
bakkle_cert_file = 'account/apn-push-prod-2015-03-30.p12.pem'
goodwill_cert_file = 'account/apn-push-prod-gw-2015-07-12.p12.pem'
key_file = 'account/apn-push-prod-2015-03-30.p12.pem'
if use_sandbox:
    bakkle_cert_file = 'account/apn-push-dev-2015-03-30.p12.pem'
    goodwill_cert_file = 'account/apn-push-prod-gw-2015-07-12.p12.pem'
    key_file = 'account/apn-push-dev-2015-03-30.p12.pem'


@run_async
def sendPushMessage(app_flavor, token, message, badge, sound):
    if app_flavor == 2:
        cert_file = goodwill_cert_file
    else:
        cert_file = bakkle_cert_file

    apns = APNs(use_sandbox=use_sandbox, cert_file=cert_file, key_file=cert_file)
    payload = Payload(alert=message, sound=soundname, badge=badge)
    print apns.gateway_server.send_notification(token, payload)

# Send multiple notifications in a single transmission
# frame = Frame()
# identifier = 1
# expiry = time.time()+3600
# priority = 10
# frame.add_item(token_hex, payload, identifier, expiry, priority)
# apns.gateway_server.send_notification_multiple(frame)
