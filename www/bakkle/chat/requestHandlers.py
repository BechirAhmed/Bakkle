
from tornado import websocket
import models
from django.db.models import Q
from account.models import Account
from account.models import Device
from models import Chat
from models import Message
from items.models import Items
from common.methods import totalUnreadMessagesForAccount
import json

clients = dict();

class ChatWSHandler(websocket.WebSocketHandler):
    clientId = None;
    uuid = None;

    #ignore origin headers
    def check_origin(self, origin):
        return True

    #on websocket open, send settings bundle
    def open(self):
        print("WebSocket opened")
        return self.write_message(json.dumps({'success': 1, 'message': 'Welcome'})) 
        

    #on receipt of message, respond accordingly.
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
    def on_message(self, message):
        # parse json message, throw error if not successful
        # print("Received message: " + str(message));
        try:
            request = json.loads(message);
            print("Received message: " + str(request));
        except ValueError:
            print("Failed");
            return self.write_message(json.dumps({'success': 0, 'error': 'Invalid parameters provided'})) 

        # authenicate, and register. Throw error if not successful
        if(not self.authenticate(request)):
            return self.write_message(json.dumps({'success': 0, 'error': 'Invalid authentication tokens'}))

        # retreive method from json dictionary, throw error if not given.
        try:
            method = request['method']
        except KeyError as e:
            return self.write_message(json.dumps({'success': 0, 'error': 'Missing parameter ' + str(e)})) 

        # switch on method, send to appropriate handlers.
        if method == 'echo':
            response = self.echo(request);
        elif method == 'registerChat':
            response = self.registerChat();
        elif method == 'startChat':
            response = self.startChat(request);
        elif method == 'getChats':
            response = self.getChats(request);
        elif method == 'sendChatMessage':
            response = self.sendChatMessage(request);
        elif method == 'test':
            response = self.test(request);
        else:
            response =  {'success': 0, 'error': 'Invalid method provided'}

        # if tag given, put it back in response.
        try:
            tag = request['tag']
            response['tag'] = tag;
        except KeyError as e:
            pass

        print("Sending message: " + json.dumps(response))
        return self.write_message(json.dumps(response))
        

    def on_close(self):
        print("WebSocket closed")
        self.deregisterChat();


    def authenticate(self, request):
        # get device object from DB. if 
        try:
            device = Device.objects.filter(uuid=request['uuid']).filter(auth_token=request['auth_token'])
            if (device is None or device == "" or len(device) == 0):
                return False
        except KeyError as e:
            return False
        except Device.DoesNotExist:
            return False

        self.clientId = int(request['auth_token'].split("_")[1]);
        self.uuid = request['uuid']
        return True;

    def echo(self, request):
        try:
            message = request['message']
        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}

        return {'success': 1, 'message': message}

    def registerChat(self):
        clients[self.clientId] = dict()
        clients[self.clientId][self.uuid] = self
        print("Registered new client for chat:");
        print(clients);
        return {'success': 1}

    def deregisterChat(self):
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

            try:
                item = Items.objects.get(pk=request['itemId'])

            except KeyError as e:
                return {'success': 0, 'error': 'Missing parameter ' + str(e)}
            except Items.DoesNotExist:
                return {'success': 0, 'error': 'Invalid itemId provided'}

            chats = Chat.objects.filter(item__seller__pk = self.clientId).filter(item = item);

        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}
        except Chat.DoesNotExist:
            chats = None;

        openChats = [];

        for chat in chats:
            # chatDict = dict(itemId = chat.item.pk, seller = self.get_account_dictionary(chat.item.seller), buyer = self.get_account_dictionary(chat.buyer));
            openChats.append(chat.toDictionary())

        return {'success': 1, 'chats': openChats}


    def sendChatMessage(self, request):
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
        Message.objects.create(chat = chat, sent_by_buyer = sentByBuyer, message = message)
        
        devices = Device.objects.filter(Q(account_id = chat.item.seller) | Q(account_id = chat.buyer))
        for device in devices:
            device.send_notification(message, len(totalUnreadMessagesForAccount(device.account_id)), "");

        if(chat.item.seller.pk in clients):
            for uuid in clients[chat.item.seller.pk]:
                clients[chat.item.seller.pk][uuid].write_message({'success': 1, 'messageOrigin': self.clientId, 'notificationType': 'newMessage', 'message': message});

        if(chat.buyer.pk in clients):
            for uuid in clients[chat.buyer.pk]:
                clients[chat.buyer.pk][uuid].write_message({'success': 1, 'messageOrigin': self.clientId, 'notificationType': 'newMessage', 'message': message});

        return {'success': 1}

    def test(self, request):

        return {'success': 1}


