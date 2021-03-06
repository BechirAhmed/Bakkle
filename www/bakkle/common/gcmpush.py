#!/usr/bin/python

from gcm import *
#from common.decorators import run_async
from tornado.log import logging

config = { "API_KEY": "AIzaSyCcb7jWxCcdLusPGp4NSHIqM6ykD8CLvcE",#AIzaSyB-jLcy_UiQPCdgkjTUI4Sqsb13G-MYxQ0",
           "pacify": False }

#@run_async
def sendGcmPushMessage(token, message, badge, sound, custom={}):

    gcm = GCM(config["API_KEY"])
    data = {'message': message,
            'badge': badge,
            'sound': sound,
            'custom': custom }


    logging.debug("Sending gcm notification " + str(data) + " to " + str(token))
    print("Sending gcm notification data={} regid={} API_KEY={}.".format(str(data), str(token), config["API_KEY"]))
    if not config["pacify"]:
        gcm.plaintext_request(registration_id=token, data=data)


