import os
import sys
import logging
import tornado.options

# import base tornado libraries
from tornado import ioloop
from tornado import web
from tornado import websocket
from tornado.log import enable_pretty_logging

# django settings must be called before importing models
import django
from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models

# import handlers
import baseWSHandlers as baseWSHandlers
import items.itemsRESTHandlers as itemsRESTHandlers
import account.accountsRESTHandlers as accountsRESTHandlers
import chat.chatWSHandlers as ChatWSHandlers

app = web.Application([

    web.url(r'^/items/test/$', itemsRESTHandlers.testHandler, name='test'),

    web.url(r'^/items/$', itemsRESTHandlers.indexHandler, name='itemIndex'),
    web.url(r'^/items/(?P<item_id>[0-9]+)/detail/$',
            itemsRESTHandlers.itemDetailHandler, name='itemDetail'),
    web.url(r'^/items/(?P<item_id>[0-9]+)/delete/$',
            itemsRESTHandlers.markDeletedHandler, name='itemMarkDelete'),
    web.url(r'^/items/(?P<item_id>[0-9]+)/spam/$',
            itemsRESTHandlers.markSpamHandler, name='itemMarkSpam'),

    web.url(r'^/items/reset/$', itemsRESTHandlers.resetHandler, name='reset'),
    web.url(r'^/items/reset_items/$',
            itemsRESTHandlers.resetItemsHandler, name='reset_items'),
    web.url(r'^/items/feed/$', itemsRESTHandlers.feedHandler, name='feed'),
    web.url(r'^/items/meh/$', itemsRESTHandlers.mehHandler, name='meh'),
    web.url(r'^/items/want/$', itemsRESTHandlers.wantHandler, name='want'),
    web.url(r'^/items/hold/$', itemsRESTHandlers.holdHandler, name='hold'),
    web.url(r'^/items/sold/$', itemsRESTHandlers.soldHandler, name='sold'),
    web.url(
        r'^/items/report/$', itemsRESTHandlers.reportHandler, name='report'),
    web.url(r'^/items/add_item/$',
            itemsRESTHandlers.addItemHandler, name='add_item'),
    web.url(r'^/items/add_item_no_image/$',
            itemsRESTHandlers.addItemNoImageHandler, name='add_item_no_image'),
    web.url(r'^/items/delete_item/$',
            itemsRESTHandlers.deleteItemHandler, name='delete_item'),
    #url(r'^sell_item/$', views.sell_item, name='sell_item'),
    # TODO: Remove the spam entry so that can no longer be reached once
    # testing is complete
    web.url(r'^/items/spam_item/$',
            itemsRESTHandlers.spamItemHandler, name='spam_item'),
    web.url(r'^/items/get_seller_items/$',
            itemsRESTHandlers.getSellerItemsHandler, name='get_seller_items'),
    web.url(r'^/items/get_seller_transactions/$',
            itemsRESTHandlers.getSellerTransactionsHandler, name='get_seller_transactions'),
    web.url(r'^/items/get_buyers_trunk/$',
            itemsRESTHandlers.getBuyersTrunkHandler, name='get_buyers_trunk'),
    web.url(r'^/items/get_holding_pattern/$',
            itemsRESTHandlers.getHoldingPatternHandler, name='get_holding_pattern'),
    web.url(r'^/items/get_buyer_transactions/$',
            itemsRESTHandlers.getBuyerTransactionsHandler, name='get_buyer_transactions'),
    web.url(r'^/items/get_delivery_methods/$',
            itemsRESTHandlers.getDeliveryMethodsHandler, name='get_delivery_methods'),


    web.url(
        r'^/account/$', accountsRESTHandlers.indexHandler, name='accountIndex'),
    web.url(r'^/account/dashboard/$',
            accountsRESTHandlers.accountDashboardHandler, name='dashboard'),
    web.url(r'^/account/(?P<account_id>[0-9]+)/detail/$',
            accountsRESTHandlers.accountDetailHandler, name='accountDetail'),
    web.url(r'^/account/(?P<account_id>[0-9]+)/reset/$',
            accountsRESTHandlers.accountResetHandler, name='accountReset'),
    web.url(r'^/account/(?P<account_id>[0-9]+)/notify/$',
            accountsRESTHandlers.deviceNotifyAllHandler, name='deviceNotifyAll'),
    web.url(r'^/account/device/(?P<device_id>[0-9]+)/detail/$',
            accountsRESTHandlers.deviceDetailHandler, name='deviceDetail'),
    web.url(r'^/account/device/(?P<device_id>[0-9]+)/notify/$',
            accountsRESTHandlers.deviceNotifyHandler, name='deviceNotify'),
    # web.url(r'^/items/(?P<account_id>[0-9]+)/spam/$', accountsRESTHandlers.markSpamHandler, name='itemMarkSpam'),

    web.url(r'^/account/login_facebook/$',
            accountsRESTHandlers.loginFacebookHandler, name='login_facebook'),
    web.url(r'^/account/logout/$',
            accountsRESTHandlers.logoutHandler, name='logout'),
    web.url(r'^/account/facebook/$',
            accountsRESTHandlers.facebookHandler, name='facebook'),
    web.url(r'^/account/settings/$',
            accountsRESTHandlers.settingsHandler, name='settings'),
    web.url(r'^/account/device/register_push/$',
            accountsRESTHandlers.deviceRegisterPushHandler, name='device_register_push'),
    web.url(r'^/account/set_description/$',
            accountsRESTHandlers.setDescriptionHandler, name='set_description'),
    web.url(r'^/account/get_account/$',
            accountsRESTHandlers.getAccountHandler, name='get_account'),


    web.url(r"/ws.*", baseWSHandlers.BaseWSHandler),
], debug=False
)

# Start the server
if __name__ == "__main__":
    # enable_pretty_logging()
    args = sys.argv
    BAKKLE_LOG_FILE = "/bakkle/log/bakkle.log"
    args.append("--log_file_prefix=" + BAKKLE_LOG_FILE)
    tornado.options.parse_command_line()
    # os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'bakkle.settings')
    django.setup()

    app.listen(8000)
    ioloop.IOLoop.instance().start()
