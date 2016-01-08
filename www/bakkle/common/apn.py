#!/usr/bin/python

from apns import APNs, Payload
from common.decorators import run_async
from tornado.log import logging

config = { "apn_cert": "apn-push-prod.pem", "apn_key": "apn-push-prod.pem", 
           "apn_cert_dev": "apn-push-dev.pem", "apn_key_dev": "apn-push-dev.pem", 
	   "apn_sandbox": False }

#@run_async
def sendPushMessage(app_flavor, token, message, badge, sound, custom={}, sandbox=config["apn_sandbox"]):
    cert_file = config["apn_cert"]
    key_file  = config["apn_key"]
    if sandbox==True:
        cert_file = config["apn_cert_dev"]
        key_file  = config["apn_key_dev"]

    #token = '963c3f72abe5dee900f066e88486272dd7e2648948abb4352ecbb52294b7317e'
    apns = APNs(use_sandbox=sandbox, cert_file=cert_file, key_file=key_file)
    payload = Payload(alert=message, sound=sound, badge=badge,custom=custom)
    logging.info("Sending notification " + str(payload) + " to " + str(token))
    print("Sending notification " + str(payload) + " to " + str(token))
    if sandbox==True:
        print("sandboxmode")
    apns.gateway_server.send_notification(token, payload)

