import os
import sys

# import base tornado libraries
from tornado import ioloop
from tornado import web
from tornado import websocket

# django settings must be called before importing models
import django
from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models

# import handlers
import baseWSRequestHandlers as baseWSRequestHandlers
import baseRESTRequestHandlers as baseRESTRequestHandlers
import items.itemsRESTRequestHandlers as itemsRESTRequestHandlers
import account.accountsRESTRequestHandlers as accountsRESTRequestHandlers
import chat.requestHandlers as chatRequestHandlers


class Message(models.Model):

    """
    Message is the django model class. In order to use it you will need to
    create the database manually.

    sqlite> CREATE TABLE message (id integer primary key, subject varchar(30),
            content varchar(250));
    sqlite> insert into message values(1, 'subject', 'cool stuff');
    sqlite> SELECT * from message;
    """

    subject = models.CharField(max_length=30)
    content = models.TextField(max_length=250)

    class Meta:
        app_label = 'dj'
        db_table = 'message'

    def __unicode__(self):
        return self.subject + "--" + self.content


class ListMessagesHandler(web.RequestHandler):

    def get(self):
        # print("Args: " + str(self.request.arguments));
        # print("Query: " + str(self.request.query));
        # print("Headers: " + str(self.request.headers));
        # print("Body: " + str(self.request.body));
        print(self.request.headers['User-Agent'])
        messages = Message.objects.all()
        self.render("templates/index.html", title="My title",
                    messages=messages)

app = web.Application([
    web.url(r'^/items/reset/$', itemsRESTRequestHandlers.resetHandler, name='reset'),
    web.url(r'^/items/reset_items/$', itemsRESTRequestHandlers.resetItemsHandler, name='reset_items'),
    web.url(r'^/items/feed/$', itemsRESTRequestHandlers.feedHandler, name='feed'),
    web.url(r'^/items/meh/$', itemsRESTRequestHandlers.mehHandler, name='meh'),
    web.url(r'^/items/want/$', itemsRESTRequestHandlers.wantHandler, name='want'),
    web.url(r'^/items/hold/$', itemsRESTRequestHandlers.holdHandler, name='hold'),
    web.url(r'^/items/sold/$', itemsRESTRequestHandlers.soldHandler, name='hold'),
    web.url(r'^/items/report/$', itemsRESTRequestHandlers.reportHandler, name='report'),
    web.url(r'^/items/add_item/$', itemsRESTRequestHandlers.addItemHandler, name='add_item'),
    web.url(r'^/items/delete_item/$', itemsRESTRequestHandlers.deleteItemHandler, name='delete_item'),
    #url(r'^sell_item/$', views.sell_item, name='sell_item'),
    # TODO: Remove the spam entry so that can no longer be reached once
    # testing is complete
    web.url(r'^/items/spam_item/$', itemsRESTRequestHandlers.spamItemHandler, name='spam_item'),
    web.url(r'^/items/get_seller_items/$', itemsRESTRequestHandlers.getSellerItemsHandler, name='get_seller_items'),
    web.url(r'^/items/get_seller_transactions/$', itemsRESTRequestHandlers.getSellerTransactionsHandler, name='get_seller_transactions'),
    web.url(r'^/items/get_buyers_trunk/$', itemsRESTRequestHandlers.getBuyersTrunkHandler, name='get_buyers_trunk'),
    web.url(r'^/items/get_holding_pattern/$', itemsRESTRequestHandlers.getHoldingPatternHandler, name='get_holding_pattern'),
    web.url(r'^/items/get_buyer_transactions/$', itemsRESTRequestHandlers.getBuyerTransactionsHandler, name='get_buyer_transactions'),
    web.url(r'^/items/get_delivery_methods/$', itemsRESTRequestHandlers.getDeliveryMethodsHandler, name='get_delivery_methods'),



    web.url(r'^/account/login_facebook/$', accountsRESTRequestHandlers.loginFacebookHandler, name='login_facebook'),
    web.url(r'^/account/logout/$', accountsRESTRequestHandlers.logoutHandler, name='logout'),
    web.url(r'^/account/facebook/$', accountsRESTRequestHandlers.facebookHandler, name='facebook'),
    web.url(r'^/account/device/register_push/$', accountsRESTRequestHandlers.deviceRegisterPushHandler, name='device_register_push'),


    #(r"/item/feed/.*", itemsRESTRequestHandlers.feedHandler),
    web.url(r"/ws.*", baseWSRequestHandlers.baseWSRequestHandler),
    # (r"/.*", baseRESTRequestHandlers.baseRESTRequestHandler),


    # (r"/ws/", chatRequestHandlers.ChatWSHandler),
    # (r"/items/[0-9]+/detail", itemsRequestHandlers.ItemRequestHandler),
    # (r"/items/[0-9]+/detail", itemsRequestHandlers.ItemRequestHandler),
], debug=True
)

# Start the server
if __name__ == "__main__":
    # os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'bakkle.settings')
    django.setup()

    app.listen(8080)
    ioloop.IOLoop.instance().start()
