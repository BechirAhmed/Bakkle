from common.bakkleRequestHandler import bakkleRequestHandler
from common.bakkleRequestHandler import QueryArgumentError

from common.decorators import run_async
from tornado.web import asynchronous

import itemsCommonHandlers

from tornado import web


class testHandler(web.RequestHandler):

    def get(self):
        itemsCommonHandlers.notify_all_new_item(
                "Testing badge notifications")


class indexHandler(bakkleRequestHandler):

    @asynchronous
    def get(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):

        item_list = itemsCommonHandlers.index()

        self.render('templates/items/index.html',
                    title="items",
                    item_list=item_list
                    )
        return


class itemDetailHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, item_id):
        self.asyncHelper(item_id)

    @run_async
    def asyncHelper(self, item_id):

        context = itemsCommonHandlers.item_detail(item_id)

        self.render('templates/items/detail.html',
                    title="items",
                    item=context['item'],
                    urls=context['urls']
                    )
        return


class markDeletedHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, item_id):
        self.asyncHelper(item_id)

    @run_async
    def asyncHelper(self, item_id):

        item_list = itemsCommonHandlers.mark_as_deleted(item_id)

        self.render('templates/items/index.html',
                    title="items",
                    item_list=item_list
                    )
        return


class markSpamHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, item_id):
        self.asyncHelper(item_id)

    @run_async
    def asyncHelper(self, item_id):

        item_list = itemsCommonHandlers.mark_as_spam(item_id)

        self.render('templates/items/index.html',
                    title="items",
                    item_list=item_list
                    )
        return


class addItemHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            # TODO: Handle location
            # Get the rest of the necessary params from the request
            title = self.getArgument('title')
            description = self.getArgument('description')
            location = self.getArgument('location')
            seller_id = self.getUser()
            price = self.getArgument('price')
            tags = self.getArgument('tags', "")
            notifyFlag = self.getArgument('notify', "")

            # Get the item id if present (If it is present an item will be edited
            # not added)
            item_id = self.getArgument('item_id', "")

            images = self.request.files['image']
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()

        self.writeJSON(itemsCommonHandlers.add_item(
            title, description, location, seller_id, price,
            tags, notifyFlag, item_id, images))
        self.finish()
        return


class addItemNoImageHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            # TODO: Handle location
            # Get the rest of the necessary params from the request
            title = self.getArgument('title')
            description = self.getArgument('description')
            location = self.getArgument('location')
            seller_id = self.getUser()
            price = self.getArgument('price')
            tags = self.getArgument('tags')
            method = self.getArgument('method')
            notifyFlag = self.getArgument('notify', "")

            # Get the item id if present (If it is present an item will be edited
            # not added)
            item_id = self.getArgument('item_id', "")

        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.add_item_no_image(
            title, description, location, seller_id, price,
            tags, method, notifyFlag, item_id))
        self.finish()


class feedHandler(bakkleRequestHandler):

    @asynchronous
    def get(self):
        self.asyncHelper()

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
            device_uuid = self.getArgument('device_uuid')
            user_location = self.getArgument('user_location')

            # TODO: Use these for filtering
            search_text = self.getArgument('search_text', "")
            filter_distance = int(self.getArgument('filter_distance'))
            filter_price = int(self.getArgument('filter_price'))
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.feed(buyer_id,
                                                device_uuid,
                                                user_location,
                                                search_text,
                                                filter_distance,
                                                filter_price))

        self.finish()


class mehHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.meh(buyer_id,
                                               item_id,
                                               view_duration))
        self.finish()


class deleteItemHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            item_id = self.getArgument('item_id')
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.delete_item(item_id))
        self.finish()


class spamItemHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            item_id = self.getArgument('item_id')
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.spam_item(item_id))
        self.finish()


class soldHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.sold(buyer_id,
                                                item_id, view_duration))
        self.finish()


class wantHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.want(buyer_id,
                                                item_id, view_duration))
        self.finish()


class holdHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.hold(buyer_id,
                                                item_id, view_duration))
        self.finish()


class reportHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            report_message = self.getArgument('report_message', "")
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.report(buyer_id,
                                                  item_id,
                                                  view_duration,
                                                  report_message))
        self.finish()


class getSellerItemsHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            seller_id = self.getUser()
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.get_seller_items(seller_id))
        self.finish()


class getSellerTransactionsHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            seller_id = self.getUser()
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(
            itemsCommonHandlers.get_seller_transactions(seller_id))
        self.finish()


class getBuyersTrunkHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.get_buyers_trunk(buyer_id))
        self.finish()


class getHoldingPatternHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(
            itemsCommonHandlers.get_holding_pattern(buyer_id))
        self.finish()


class getBuyerTransactionsHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(
            itemsCommonHandlers.get_buyer_transactions(buyer_id))
        self.finish()


class getDeliveryMethodsHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):

        if(not self.authenticate()):
            self.writeJSON({'success': 0, 'error': 'Device not authenticated'})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.get_delivery_methods())
        self.finish()


class resetHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):
        try:

            if(not self.authenticate()):
                self.writeJSON(
                    {'success': 0, 'error': 'Device not authenticated'})
                self.finish()
                return

            buyer_id = self.getUser()
        except QueryArgumentError as error:
            self.writeJSON({"status": 0, "message": error.message})
            self.finish()
            return

        self.writeJSON(itemsCommonHandlers.reset(buyer_id))
        self.finish()


class resetItemsHandler(bakkleRequestHandler):

    @asynchronous
    def post(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):

        self.writeJSON(itemsCommonHandlers.reset_items())
        self.finish()
        return
