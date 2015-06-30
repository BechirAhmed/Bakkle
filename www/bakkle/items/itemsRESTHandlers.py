from common.bakkleRequestHandler import bakkleRequestHandler
from common.bakkleRequestHandler import QueryArgumentError

from common.decorators import run_async

import itemsCommonHandlers


class addItemHandler(bakkleRequestHandler):

    def post(self):
        try:

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

            images = self.request.files['image']
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        self.writeJSON(itemsCommonHandlers.add_item(
            title, description, location, seller_id, price,
            tags, method, notifyFlag, item_id, images))

class addItemNoImageHandler(bakkleRequestHandler):

    def post(self):
        try:

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
            return self.writeJSON({"status": 0, "message": error.message})

        self.writeJSON(itemsCommonHandlers.add_item_no_image(
            title, description, location, seller_id, price,
            tags, method, notifyFlag, item_id))


class feedHandler(bakkleRequestHandler):

    @run_async
    def get(self):
        try:
            buyer_id = self.getUser()
            device_uuid = self.getArgument('device_uuid')
            user_location = self.getArgument('user_location')

            # TODO: Use these for filtering
            search_text = self.getArgument('search_text', "")
            filter_distance = int(self.getArgument('filter_distance'))
            filter_price = int(self.getArgument('filter_price'))
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.feed(buyer_id, device_uuid,
        # user_location, search_text, filter_distance, filter_price)
        self.writeJSON(itemsCommonHandlers.feed(buyer_id,
                                                device_uuid,
                                                user_location,
                                                search_text,
                                                filter_distance,
                                                filter_price))

    def post(self):
        try:
            buyer_id = self.getUser()
            device_uuid = self.getArgument('device_uuid')
            user_location = self.getArgument('user_location')

            # TODO: Use these for filtering
            search_text = self.getArgument('search_text', "")
            filter_distance = int(self.getArgument('filter_distance'))
            filter_price = int(self.getArgument('filter_price'))
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.feed(buyer_id, device_uuid,
        # user_location, search_text, filter_distance, filter_price)
        self.writeJSON(itemsCommonHandlers.feed(buyer_id,
                                                device_uuid,
                                                user_location,
                                                search_text,
                                                filter_distance,
                                                filter_price))


class mehHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.meh(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.meh(buyer_id,
                                               item_id,
                                               view_duration))


class deleteItemHandler(bakkleRequestHandler):

    def post(self):
        try:
            item_id = self.getArgument('item_id')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        self.writeJSON(itemsCommonHandlers.delete_item(item_id))


class spamItemHandler(bakkleRequestHandler):

    def post(self):
        try:
            item_id = self.getArgument('item_id')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        self.writeJSON(itemsCommonHandlers.spam_item(item_id))


class soldHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.sold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.sold(buyer_id,
                                                item_id, view_duration))


class wantHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.want(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.want(buyer_id,
                                                item_id, view_duration))


class holdHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.hold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.hold(buyer_id,
                                                item_id, view_duration))


class reportHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
            item_id = self.getArgument('item_id')
            view_duration = self.getArgument('view_duration', 0)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.report(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.report(buyer_id,
                                                  item_id,
                                                  view_duration))


class getSellerItemsHandler(bakkleRequestHandler):

    def post(self):
        try:
            seller_id = self.getUser()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.sold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.get_seller_items(seller_id))


class getSellerTransactionsHandler(bakkleRequestHandler):

    def post(self):
        try:
            seller_id = self.getUser()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.sold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(
            itemsCommonHandlers.get_seller_transactions(seller_id))


class getBuyersTrunkHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.sold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.get_buyers_trunk(buyer_id))


class getHoldingPatternHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.sold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(
            itemsCommonHandlers.get_holding_pattern(buyer_id))


class getBuyerTransactionsHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.sold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(
            itemsCommonHandlers.get_buyer_transactions(buyer_id))


class getDeliveryMethodsHandler(bakkleRequestHandler):

    def post(self):

        self.writeJSON(itemsCommonHandlers.get_delivery_methods())


class resetHandler(bakkleRequestHandler):

    def post(self):
        try:
            buyer_id = self.getUser()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # return itemsCommonHandlers.sold(buyer_id, item_id,
        # view_duration)
        self.writeJSON(itemsCommonHandlers.reset(buyer_id))


class resetItemsHandler(bakkleRequestHandler):

    def post(self):

        self.writeJSON(itemsCommonHandlers.reset_items())
