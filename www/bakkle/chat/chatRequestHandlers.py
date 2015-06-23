
from django.db.models import Q
from account.models import Account
from account.models import Device
from models import Chat
from models import Message
from items.models import Items
from common.methods import totalUnreadMessagesForAccount


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
                response = self.startChat(
                    request['itemId'], self.baseWSHandler.clientId)
            elif method == 'getChatIds':
                response = self.getChatIds(
                    request['itemId'], self.baseWSHandler.clientId)
            elif method == 'sendChatMessage':
                response = self.sendChatMessage(
                    request['chatId'], self.baseWSHandler.clientId, request['message'])
            elif method == 'getMessagesForChat':
                response = self.getMessagesForChat(
                    request['chatId'], self.baseWSHandler.clientId)
            else:
                response = {
                    'success': 0, 'error': 'Invalid chat method provided'}
        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter: ' + str(e) + ' for method: ' + method}

        return response

    def handleClose(self):
        pass

    def startChat(self, itemId, buyerId):
        try:
            item = Items.objects.get(pk=itemId)
            buyer = Account.objects.get(pk=buyerId)

            if(item.seller == buyer):
                return {'success': 0, 'error': 'Cannot start chat session with yourself.'}

            chat = Chat.objects.get_or_create(
                item=item,
                buyer=buyer)[0]

        except Items.DoesNotExist:
            return {'success': 0, 'error': 'Invalid itemId provided'}
        except Account.DoesNotExist:
            return {'success': 0, 'error': 'Invalid buyerId provided'}

        return {'success': 1, 'chatId': chat.pk}

    def getChatIds(self, itemId, sellerId):

        try:
            item = Items.objects.get(pk=itemId)
            seller = Account.objects.get(pk=sellerId)

        except Items.DoesNotExist:
            return {'success': 0, 'error': 'Invalid itemId provided'}
        except Account.DoesNotExist:
            return {'success': 0, 'error': 'Invalid sellerId provided'}

        try:
            chats = Chat.objects.filter(item=item)

        except Chat.DoesNotExist:
            chats = None

        openChats = []

        for chat in chats:
            openChats.append(chat.toDictionary())

        return {'success': 1, 'chats': openChats}

    def sendChatMessage(self, chatId, senderId, message):
        try:
            message = message
            chat = Chat.objects.get(pk=chatId)
            sender = Account.objects.get(pk=senderId)

        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}
        except Chat.DoesNotExist:
            return {'success': 0, 'error': 'Invalid chatId provided'}
        except Account.DoesNotExist:
            return {'success': 0, 'error': 'Invalid senderId provided'}

        if(sender != chat.item.seller and sender != chat.buyer):
            return {'success': 0, 'error': 'Invalid chatId provided - user not involved in specified chat.'}

        sentByBuyer = (sender == chat.buyer)
        newMessage = Message.objects.create(
            chat=chat, sent_by_buyer=sentByBuyer, message=message)

        devices = Device.objects.filter(
            Q(account_id=chat.item.seller) | Q(account_id=chat.buyer))
        for device in devices:
            device.send_notification(
                message, len(totalUnreadMessagesForAccount(device.account_id)), "")

        if(chat.item.seller.pk in self.baseWSHandler.clients):
            for uuid in clients[chat.item.seller.pk]:
                self.baseWSHandler.clients[chat.item.seller.pk][uuid].write_message(
                    {'success': 1, 'messageOrigin': senderId, 'notificationType': 'newMessage', 'message': newMessage.toDictionary()})

        if(chat.buyer.pk in self.baseWSHandler.clients):
            for uuid in clients[chat.buyer.pk]:
                self.baseWSHandler.clients[chat.buyer.pk][uuid].write_message(
                    {'success': 1, 'messageOrigin': senderId, 'notificationType': 'newMessage', 'message': newMessage.toDictionary()})

        return {'success': 1}

    def getMessagesForChat(self, chatId, requesterId):
        try:

            chat = Chat.objects.get(pk=chatId)
            requester = Account.objects.get(pk=requesterId)

            if(requester != chat.item.seller and requester != chat.buyer):
                return {'success': 0, 'error': 'Invalid chatId provided - user not involved in specified chat.'}

            messages = Message.objects.filter(chat=chat).order_by('-date_sent')

        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}
        except Chat.DoesNotExist:
            return {'success': 0, 'error': 'Invalid chatId provided'}
        except Account.DoesNotExist:
            return {'success': 0, 'error': 'Invalid senderId provided'}

        userMessages = []

        for message in messages:
            userMessages.append(message.toDictionary())

        print(userMessages)
        return {'success': 1, 'messages': userMessages}
