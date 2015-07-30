

import chatCommonHandlers

from decimal import *

# import baseWSHandlers


class ChatWSHandler():

    def __init__(self, baseWSHandler):
        self.baseWSHandler = baseWSHandler

    # on websocket open, send settings bundle
    def handleOpen(self):
        pass

    # on receipt of message, respond accordingly.
    # Example Request:
    # {"method": "registerChat", "auth_token": "asdfasdfasdfasdf_2", "uuid": "E6264D84-C395-4132-8C63-3EF051480191"}
    # {"method": "registerChat", "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B"}
    #
    # test server
    # {"method": "registerChat", "auth_token": "df4727b2641a70cbda5f2d64c9a8d1a3_10", "uuid": "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB"}
    # {"method": "getChats", "auth_token": "d584ca08924596eb3e8809ed586a24db_10", "uuid": "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB", "itemId": 12}
    #
    # {"method": "startChat", "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B", "itemId": 12}
    # {"method": "sendChatMessage", "chatId": _____, "auth_token": "asdfasdfasdfasdf_2", "uuid": "E6264D84-C395-4132-8C63-3EF051480191", "message": "test"}
    # {"method": "sendChatMessage", "chatId": _____, "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B", "message": "test2"}
    def handleRequest(self, request):

        # retreive method from json dictionary, throw error if not given.
        try:
            method = request['method'].split("_")[1]
        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}

        # switch on method, send to appropriate handlers.
        try:
            if method == 'startChat':
                response = chatCommonHandlers.startChat(
                    request['itemId'], self.baseWSHandler.clientId)
            elif method == 'getChatIds':
                response = chatCommonHandlers.getChatIds(
                    request['itemId'], self.baseWSHandler.clientId)
            elif method == 'sendChatMessage':
                response = chatCommonHandlers.sendChatMessage(
                    self.baseWSHandler.clients,
                    request['chatId'],
                    self.baseWSHandler.clientId,
                    request['message'],
                    request['offerPrice'],
                    request['offerMethod'])
            elif method == 'getMessagesForChat':
                response = chatCommonHandlers.getMessagesForChat(
                    request['chatId'], self.baseWSHandler.clientId)
            else:
                response = {
                    'success': 0, 'error': 'Invalid chat method provided'}
        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter: ' +
                    str(e) + ' for method: ' + method}

        return response

    def handleClose(self):
        pass
