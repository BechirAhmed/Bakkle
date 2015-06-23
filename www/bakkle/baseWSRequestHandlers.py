
from chat.chatRequestHandlers import ChatWSHandler
import json

from account.models import Account
from account.models import Device
from django.db.models import Q
from items.models import Items
from chat.models import Chat
from chat.models import Message
from tornado import websocket

from common.sysVars import getSysVars

class baseWSRequestHandler(websocket.WebSocketHandler):

    clients = dict();

    # def __init__(self, application, request, **kwargs):
    #     websocket.WebSocketHandler.__init__(self, application, request,
    #                                         **kwargs)
    #     self.clientId = 

    #ignore origin headers
    def check_origin(self, origin):
        return True

    #TODO: on websocket open, send settings bundle
    def open(self):
        print("WebSocket opened");
        try:
            self.clientId = str(self.request.query_arguments['userId'][0])
            self.uuid = str(self.request.query_arguments['uuid'][0])
        except KeyError as e:
            self.write_message(json.dumps({'success': 0, 'error': 'Missing parameter ' + str(e)}))
            return self.close();

        self.register();

        self.chatWSHandler = ChatWSHandler(self);
        self.chatWSHandler.handleOpen();
        return self.write_message(json.dumps({'success': 1, 'message': 'Welcome'}))  

    #on receipt of message, respond accordingly.
    # Example Request: 
    # {"method": "registerChat", "auth_token": "asdfasdfasdfasdf_2", "uuid": "E6264D84-C395-4132-8C63-3EF051480191"}
    # {"method": "registerChat", "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B"}
    #
    # {"method": "startChat", "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B", "itemId": 12}
    # {"method": "sendChatMessage", "chatId": _____, "auth_token": "asdfasdfasdfasdf_2", "uuid": "E6264D84-C395-4132-8C63-3EF051480191", "message": "test"}
    # {"method": "sendChatMessage", "chatId": _____, "auth_token": "4c708bda45351147d32b5c3f541b76ba_3", "uuid": "81FEEEDD-C99C-4E50-B671-4302F146441B", "message": "test2"}
    def on_message(self, message):
        # parse json message, throw error if invalid JSON
        # print("Received message: " + str(message));
        try:
            request = json.loads(message);
        except ValueError:
            print("Parsing JSON failed on string: " + message);
            return self.write_message(json.dumps({'success': 0, 'error': 'Invalid parameters provided'})) 

        # authenicate, and register. Throw error if not successful
        if(not self.authenticate(request)):
            return self.write_message(json.dumps({'success': 0, 'error': 'Invalid credentials'}))

        # retreive method from json dictionary, throw error if not given.
        try:
            method = request['method']
        except KeyError as e:
            return self.write_message(json.dumps({'success': 0, 'error': 'Missing parameter ' + str(e)})) 


        response =  {'success': 0, 'error': 'Invalid method provided'}

        if not "_" in method:
            if method == 'echo':
                response = self.echo(request)
            elif method == 'sysVars':
                response = self.sysVars()

        elif method.split("_")[0] == "chat":
            response = self.chatWSHandler.handleRequest(request)

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
        self.chatWSHandler.handleClose()
        self.deregister();


    def authenticate(self, request):
        # get device object from DB. if 
        try:
            if(self.uuid != request['uuid'] or self.clientId != request['auth_token'].split("_")[1]):
                print("UUID or clientId changed. Invalid credentials.")
                return False;

            device = Device.objects.filter(uuid=request['uuid']).filter(auth_token=request['auth_token'])
            if (device is None or device == "" or len(device) == 0):
                return False
        except KeyError as e:
            return False
        except Device.DoesNotExist:
            return False

        return True;
    
    def register(self):
        BaseWSHandler.clients[self.clientId] = dict()
        BaseWSHandler.clients[self.clientId][self.uuid] = self
        print("Registered new client for notifications: " + self.clientId);
        return {'success': 1}

    def deregister(self):
        if self.clientId in BaseWSHandler.clients:
            # if empty, or will be empty, delete the nested dictionary
            if(len(BaseWSHandler.clients[self.clientId]) <= 1):
                dictionary = BaseWSHandler.clients;
                del dictionary[self.clientId]
            # otherwise, just delete the respective entry.
            else:
                dictionary = BaseWSHandler.clients[self.clientId];
                del dictionary[self.uuid]
        print("Deregistered client from notifications: " + self.clientId);
        return {'success': 1}   

    def echo(self, request):
        try:
            message = request['message']
        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}

        return {'success': 1, 'message': message}

    def sysVars(self, request):
        return {'success': 1, 'sysVars': getSysVars()}
