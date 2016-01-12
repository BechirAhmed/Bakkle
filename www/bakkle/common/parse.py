#!/usr/bin/python

import json,httplib
from common.decorators import run_async
from tornado.log import logging

config = { "X-Parse-Application-Id": "sxjMPMgXvXLMAGddMk4Zy9U8PKkvGP0N8MzBjiVg",
           "X-Parse-REST-API-Key": "x6QGCkHKQxYxGDLlK0yaKHGgqkmu06pTBSjVZMPI" }

#@run_async
def sendPushMessage(token, message, badge, sound, custom={}):
    logging.debug("Sending notification " + str(payload) + " to " + str(token))
    print("Sending notification " + str(payload) + " to " + str(token))

    connection = httplib.HTTPSConnection('api.parse.com', 443)
    connection.connect()
    connection.request('POST', '/1/push', json.dumps({
                "channels": [
                    "Indians"
                    ],
                "data": {
                    "action": "com.example.UPDATE_STATUS",
                    "alert": "Ricky Vaughn was injured during the game last night!",
                    "name": "Vaughn",
                    "newsItem": "Man bites dog"
                    }
                }), {
            "X-Parse-Application-Id": config["X-Parse-Application-Id"],
            "X-Parse-REST-API-Key":   config["X-Parse-REST-API-Key"],
            "Content-Type": "application/json"
            })
    result = json.loads(connection.getresponse().read())
    print("Result: {}".format(result))
    logging.info("Result: {}".format(result))

