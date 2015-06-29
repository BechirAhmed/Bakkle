

from account.models import Account
from models import Offer
from models import Sale

# import baseWSHandlers


class PurchaseWSHandler():

    def __init__(self, baseWSHandler):
        self.baseWSHandler = baseWSHandler

    # on websocket open, send settings bundle
    def handleOpen(self):
        pass

    def handleRequest(self, request):

        # retreive method from json dictionary, throw error if not given.
        try:
            method = request['method'].split("_")[1]
        except KeyError as e:
            return {'success': 0, 'error': 'Missing parameter ' + str(e)}

        # switch on method, send to appropriate handlers.
        try:
            if method == 'acceptOffer':
                response = self.acceptOffer(
                    request['offerId'], self.baseWSHandler.clientId)
            elif method == 'retractOffer':
                response = self.retractOffer(
                    request['offerId'], self.baseWSHandler.clientId)
            else:
                response = {
                    'success': 0, 'error': 'Invalid purchase method provided'}
        except KeyError as e:
            return {
                'success': 0,
                'error': 'Missing parameter: ' + str(e) +
                ' for method: ' + method}

        return response

    def handleClose(self):
        pass

    def acceptOffer(self, offerId, buyerId):
        try:
            offer = Offer.objects.get(pk=offerId)
            item = offer.item
            buyer = Account.objects.get(pk=buyerId)
        except Offer.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid itemId provided'}
        except Account.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid buyerId provided'}

        if(offer.status != "Active"):
            return {
                'success': 0,
                'error': 'Offer has already been ' + str(offer.status)}

        if(item.status == "Sold"):
            return {
                'success': 0,
                'error': 'Item already sold!'}

        if(offer.sent_by_buyer is True and offer.buyer == buyer):
            return {
                'success': 0,
                'error': 'Cannot accept your own offer'}

        offer.status = "Accepted"
        offer.save()

        Sale.objects.create(
            item=item,
            acceptedOffer=offer)

        item.status = "Sold"
        item.save()

        Offer.objects.filter(item=item).filter(
            status="Active").update(status="Retracted")

        return {'success': 1}

    def retractOffer(self, offerId, sellerId):
        try:
            offer = Offer.objects.get(pk=offerId)
            item = offer.item
            seller = Account.objects.get(pk=sellerId)

        except Offer.DoesNotExist:
            return {'success': 0, 'error': 'Invalid itemId provided'}
        except Account.DoesNotExist:
            return {'success': 0, 'error': 'Invalid buyerId provided'}

        if(offer.status != "Active"):
            return {
                'success': 0,
                'error': 'Offer has already been ' + str(offer.status)
            }

        if(offer.sent_by_buyer is False and item.seller == seller):
            return {
                'success': 0,
                'error': "Cannot retract someone else's offer"
            }

        offer.status = "Retracted"
        offer.save()

        return {'success': 1}
