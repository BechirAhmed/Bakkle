
from chat.chatRequestHandlers import ChatWSHandler
import json
from tornado import web

from account.models import Account
from account.models import Device
from django.db.models import Q
from items.models import Items
from chat.models import Chat
from chat.models import Message
from common.bakkleRequestHandler import bakkleRequestHandler

from common.sysVars import getSysVars


class baseRESTRequestHandler(bakkleRequestHandler):

    def get(self):
        pathItems = self.request.uri.split("/")

        while(pathItems.count("") > 0):
            pathItems.remove("")

        queryParams = self.getQueryArgument("test")

        self.write(
            {'success': 1, 'message': 'test', 'uri': pathItems, 'queryParams': queryParams})

        return
    # print("Args: " + str(self.request.arguments));
    # print("Query: " + str(self.request.query));
    # print("Headers: " + str(self.request.headers));
    # print("Body: " + str(self.request.body));
    # print(self.request.headers['User-Agent'])
    # messages = Message.objects.all()
    # self.render("templates/index.html", title="My title",
    #             messages=messages)

    def post(self):
        pathItems = self.request.uri.split("/")

        while(pathItems.count("") > 0):
            pathItems.remove("")

        queryParams = self.getQueryArgument("test")

        self.write({'success': 1, 'message': 'test', 'uri': pathItems, 'files': str(
            self.request.files['test'])})
        return