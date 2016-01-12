#!/usr/bin/python

from gcm import *
from common.decorators import run_async
from tornado.log import logging

config = { "reg_id": "AIzaSyCcb7jWxCcdLusPGp4NSHIqM6ykD8CLvcE",#AIzaSyB-jLcy_UiQPCdgkjTUI4Sqsb13G-MYxQ0",
           "pacify": False }

#@run_async
def sendGcmPushMessage(token, message, badge, sound, custom={}):

    gcm = GCM(config["reg_id"])
    data = {'message': message,
            'badge': badge,
            'sound': sound,
            'custom': custom }


    logging.debug("Sending gcm notification " + str(data) + " to " + str(token))
    print("Sending gcm notification data={} regid={}.".format(str(data), str(token)))
    if not config["pacify"]:
        gcm.plaintext_request(registration_id=token, data=data)


