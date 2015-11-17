#!/usr/bin/python

from apns import APNs, Payload
from common.decorators import run_async
from tornado.log import logging

config = { "apn_cert": "apn-push-prod.pem", "apn_key": "apn-push-prod.pem", "apn_sandbox": False }

#@run_async
def sendPushMessage(app_flavor, token, message, badge, sound, custom={}):
    cert_file = config["apn_cert"]
    #token = '963c3f72abe5dee900f066e88486272dd7e2648948abb4352ecbb52294b7317e'
    apns = APNs(use_sandbox=config["apn_sandbox"], cert_file=config["apn_cert"], key_file=config["apn_key"])
    payload = Payload(alert=message, sound=sound, badge=badge,custom=custom)
    logging.debug("Sending notification " + str(payload) + " to " + str(token))
    apns.gateway_server.send_notification(token, payload)

