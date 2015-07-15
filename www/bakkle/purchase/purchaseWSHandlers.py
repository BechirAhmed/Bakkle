

from account.models import Account
from models import Offer
from models import Sale
from django.db.models import Avg

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

    def acceptOffer(self, offerId, userId):
        try:
            offer = Offer.objects.get(pk=offerId)
            item = offer.item
            user = Account.objects.get(pk=userId)
        except Offer.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid itemId provided'}
        except Account.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid userId provided'}

        if(offer.status != "Active"):
            return {
                'success': 0,
                'error': 'Offer has already been ' + str(offer.status)}

        if(item.status == "Sold"):
            return {
                'success': 0,
                'error': 'Item already sold!'}

        if((offer.sent_by_buyer is True and offer.buyer == user) or (offer.sent_by_buyer is False and offer.item.seller == user)):
            return {
                'success': 0,
                'error': 'Cannot accept your own offer'}

        offer.status = "Accepted"
        offer.save()

        sale = Sale.objects.create(
            item=item,
            acceptedOffer=offer)

        item.status = "Sold"
        item.save()

        Offer.objects.filter(item=item).filter(
            status="Active").update(status="Retracted")

        return {'success': 1, 'saleId': sale.pk}

    def retractOffer(self, offerId, userId):
        try:
            offer = Offer.objects.get(pk=offerId)
            item = offer.item
            user = Account.objects.get(pk=userId)

        except Offer.DoesNotExist:
            return {'success': 0, 'error': 'Invalid itemId provided'}
        except Account.DoesNotExist:
            return {'success': 0, 'error': 'Invalid buyerId provided'}

        if(offer.status != "Active"):
            return {
                'success': 0,
                'error': 'Offer has already been ' + str(offer.status)
            }

        if((offer.sent_by_buyer is True and offer.buyer != user) or (offer.sent_by_buyer is False and offer.item.seller != user)):
            return {
                'success': 0,
                'error': "Cannot retract someone else's offer"
            }

        offer.status = "Retracted"
        offer.save()

        return {'success': 1}

    def getRatings(self, userId, numRatings):
        try:
            user = Account.objects.get(pk=userId)
        except Account.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid userId provided'}

        sales = Sale.objects.filter(
            Q(item__seller=user) | Q(buyer=user))[:numRatings]

        ratings = []
        for sale in sales:
            ratings.append(
                {'rating': sale.buyer_rating, 'description': sale.buyer_rating_description})

    def rateSeller(self, userId, saleId, rating, description):
        try:
            sale = Sale.objects.get(pk=saleId)
            seller = sale.item.seller
            user = Account.objects.get(pk=userId)
            rating = int(rating)
        except Sale.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid saleId provided'}
        except Account.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid userId provided'}
        except ValueError:
            return {
                'success': 0,
                'error': 'Invalid rating provided'}

        if(sale.buyer != user):
            return {
                'success': 0,
                'error': 'Cannot rate seller if not buyer'
            }
        if(rating < 0 or rating > 5):
            return {
                'success': 0,
                'error': 'Invalid Rating'
            }

        sale.seller_rating = rating
        sale.seller_rating_description = description
        sale.save()

        seller.seller_rating = Sale.objects.filter(item__seller=seller).aggregate(
            averageSellerRating=Avg('seller_rating'))['averageSellerRating']
        seller.save()

        return {'success': 1}

    def rateBuyer(self, userId, saleId, rating, description):
        try:
            sale = Sale.objects.get(pk=saleId)
            buyer = sale.buyer
            user = Account.objects.get(pk=userId)
            rating = int(rating)
        except Sale.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid saleId provided'}
        except Account.DoesNotExist:
            return {
                'success': 0,
                'error': 'Invalid userId provided'}
        except ValueError:
            return {
                'success': 0,
                'error': 'Invalid rating provided'}

        if(sale.item.seller != user):
            return {
                'success': 0,
                'error': 'Cannot rate buyer if not seller'
            }
        if(rating < 0 or rating > 5):
            return {
                'success': 0,
                'error': 'Invalid Rating'
            }

        sale.buyer_rating = rating
        sale.buyer_rating_description = description
        sale.save()

        buyer.buyer_rating = Sale.objects.filter(buyer=buyer).aggregate(
            averageBuyerRating=Avg('buyer_rating'))['averageBuyerRating']
        buyer.save()

        return {'success': 1}
