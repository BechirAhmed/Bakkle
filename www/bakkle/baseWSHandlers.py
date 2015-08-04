
from chat.chatWSHandlers import ChatWSHandler
from purchase.purchaseWSHandlers import PurchaseWSHandler
import json

from account.models import Account
from account.models import Device
from django.db.models import Q
from items.models import Items
from chat.models import Chat
from chat.models import Message
from tornado import websocket

from common.sysVars import getSysVars

class BaseWSHandler(websocket.WebSocketHandler):

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

        self.clientId = None;
        self.uuid = None;
        self.chatWSHandler = None;
        self.purchaseWSHandler = None;
        # self.itemsWSHandler = None;

        try:
            self.clientId = int(self.request.query_arguments['userId'][0])
            self.uuid = str(self.request.query_arguments['uuid'][0])
        except KeyError as e:
            self.write_message(json.dumps({'success': 0, 'error': 'Missing parameter ' + str(e)}))
            return self.close();
        except ValueError:
            self.write_message(json.dumps({'success': 0, 'error': 'Invalid parameter userId'}))
            return self.close();

        self.register();

        self.chatWSHandler = ChatWSHandler(self);
        self.chatWSHandler.handleOpen();

        self.purchaseWSHandler = PurchaseWSHandler(self);
        self.purchaseWSHandler.handleOpen();
        return self.write_message(json.dumps({'success': 1, 'message': 'Welcome'}))  

    #on receipt of message, respond accordingly.
    def on_message(self, message):
        # parse json message, throw error if invalid JSON
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

        elif method.split("_")[0] == "purchase":
            response = self.purchaseWSHandler.handleRequest(request)

        # if tag given, put it back in response.
        try:
            tag = request['tag']
            response['tag'] = tag;
        except KeyError as e:
            pass

        # print("Sending message: " + json.dumps(response))
        return self.write_message(json.dumps(response))
        

    def on_close(self):
        print("WebSocket closed")
        if (self.chatWSHandler is not None):
            self.chatWSHandler.handleClose()
        if (self.purchaseWSHandler is not None):
            self.purchaseWSHandler.handleClose()
        self.deregister()


    def authenticate(self, request):
        # get device object from DB. if 
        try:
            if(self.uuid != request['uuid'] or str(self.clientId) != request['auth_token'].split("_")[1]):
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
        print("Registered new client for notifications: " + str(self.clientId));
        return {'success': 1}

    def deregister(self):
        if ((self.clientId is not None) and (self.clientId in BaseWSHandler.clients)):
            # if empty, or will be empty, delete the nested dictionary
            if(len(BaseWSHandler.clients[self.clientId]) <= 1):
                dictionary = BaseWSHandler.clients;
                del dictionary[self.clientId]
            # otherwise, just delete the respective entry.
            elif(self.uuid is not None):
                dictionary = BaseWSHandler.clients[self.clientId];
                del dictionary[self.uuid]
        print("Deregistered client from notifications: " + str(self.clientId))
        return {'success': 1}   

    def echo(self, request):
        try:
            message = request['message']
        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}

        return {'success': 1, 'message': message}

    def sysVars(self, request):
        return {'success': 1, 'sysVars': getSysVars()}
