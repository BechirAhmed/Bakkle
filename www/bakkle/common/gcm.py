#!/usr/bin/python

from gcm import *
from common.decorators import run_async
from tornado.log import logging

config = { "reg_id": "AIzaSyB-jLcy_UiQPCdgkjTUI4Sqsb13G-MYxQ0",
           "pacify": False }

#@run_async
def sendPushMessage(token, message, badge, sound, custom={}):

    gcm = GCM("AIzaSyDejSxmynqJzzBdyrCS-IqMhp0BxiGWL1M")
    data = {'message': message,
            'badge': badge,
            'sound': sound,
            'custom': custom }


    logging.debug("Sending notification " + str(payload) + " to " + str(token))
    print("Sending notification " + str(payload) + " to " + str(token))
    if not config["pacify"]:
        gcm.plaintext_request(registration_id=config[reg_id], data=data)


