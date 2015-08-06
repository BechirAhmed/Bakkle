import chatCommonHandlers

from decimal import *

# import baseWSHandlers


class ChatWSHandler():

    def __init__(self, baseWSHandler):
        self.baseWSHandler = baseWSHandler

    # on websocket open, send settings bundle
    def handleOpen(self):
        pass

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
            return {'success': 0, 'error': 'Missing parameter: ' + str(e) +
                    ' for method: ' + method}

        return response

    def handleClose(self):
        pass
