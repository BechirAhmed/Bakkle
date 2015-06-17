

import json

from account.models import Account
from account.models import Device
from django.db.models import Q
from items.models import Items
from models import Chat
from models import Message
from tornado import websocket


class WSHandler:

    clients = dict();

    def __init__(self, baseHandler):
        self.baseHandler = baseHandler

    #on websocket open, send settings bundle
    def handleOpen(self):
        pass

    #on receipt of message, respond accordingly.
    # Example Request: 
    # {"method": "registerChat", "auth_token": "asdfasdfasdfasdf_2", "uuid": "E6264D84-C395-4132-8C63-3EF051480191"}
    # {"method": "registerChat", "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B"}
    #
    # {"method": "startChat", "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B", "itemId": 12}
    # {"method": "sendChatMessage", "chatId": _____, "auth_token": "asdfasdfasdfasdf_2", "uuid": "E6264D84-C395-4132-8C63-3EF051480191", "message": "test"}
    # {"method": "sendChatMessage", "chatId": _____, "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B", "message": "test2"}
    def handleRequest(self, request):
        # retreive method from json dictionary, throw error if not given.
        try:
            method = request['method'].split("_")[1]
        except KeyError as e:
            return json.dumps({'success': 0, 'error': 'Missing parameter ' + str(e)})

        # switch on method, send to appropriate handlers.
        if method == 'register':
            return self.register();
        elif method == 'startChat':
            return self.startChat(request);
        elif method == 'getChats':
            return self.getChats(request);
        elif method == 'sendMessage':
            return self.sendMessage(request);
        else:
            return {'success': 0, 'error': 'Invalid method provided'}
        

    def handleClose(self):
        print("Deconstructing WSHandler")
        self.deregisterChat();

    def register(self):
        clients[self.clientId] = dict()
        clients[self.clientId][self.uuid] = self
        print("Registered new client for chat:");
        print(clients);
        return {'success': 1}

    def deregister(self):
        if self.clientId in clients:
            if(len(clients[self.clientId]) == 1):
                dictionary = clients;
                del dictionary[self.clientId]
            else:
                dictionary = clients[self.clientId];
                del dictionary[self.uuid]
        print(clients);
        return {'success': 1}

    def startChat(self, request):
        try:
            item = Items.objects.get(pk=request['itemId'])
            buyer = Account.objects.get(pk=self.clientId);

            if(item.seller.pk == buyer or item.seller.pk == self.clientId):
                return {'success': 0, 'error': 'Cannot start chat session with yourself.'}

            chat = Chat.objects.get_or_create(
                item = item,
                buyer = buyer)[0]

        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}
        except Items.DoesNotExist:
            return {'success': 0, 'error': 'Invalid itemId provided'}
        except Account.DoesNotExist:
            return {'success': 0, 'error': 'Invalid buyerId provided'}

        return {'success': 1, 'chatId': chat.pk}

    def getChats(self, request):
        try:

            chats = Chat.objects.filter(Q(item__seller__pk = self.clientId) | Q(buyer__pk = self.clientId));

        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}
        except Chat.DoesNotExist:
            chats = None;

        openChats = [];

        for chat in chats:
            chatDict = dict(itemId = chat.item.pk, seller = chat.item.seller.pk, buyer = chat.buyer.pk);
            openChats.append(chatDict)

        return {'success': 1, 'chats': openChats}


    def sendMessage(self, request):
        try:
            message = request['message']
            chat = Chat.objects.get(pk=request['chatId'])

        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}
        except Chat.DoesNotExist:
            return {'success': 0, 'error': 'Invalid chatId provided'}


        if(self.clientId != chat.item.seller.pk and self.clientId != chat.buyer.pk):
            return {'success': 0, 'error': 'Invalid chatId provided - user not involved in specified chat.'}

        sentByBuyer = (self.clientId == chat.buyer.pk)
        Message.objects.create(chat_id = chat, sent_by_buyer = sentByBuyer, message = message)
        
        if(chat.item.seller.pk in clients):
            for uuid in clients[chat.item.seller.pk]:
                clients[chat.item.seller.pk][uuid].write_message({'success': 1, 'messageOrigin': self.clientId, 'notificationType': 'newMessage', 'message': message});

        if(chat.buyer.pk in clients):
            for uuid in clients[chat.buyer.pk]:
                clients[chat.buyer.pk][uuid].write_message({'success': 1, 'messageOrigin': self.clientId, 'notificationType': 'newMessage', 'message': message});

        return {'success': 1}

