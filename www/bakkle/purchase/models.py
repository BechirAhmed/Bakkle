from django.db import models
from account.models import Account
from items.models import Items

# Create your models here.


class Offer(models.Model):

    PICK_UP = 'Pick-up'
    DELIVERY = 'Delivery'
    MEET = 'Meet'
    SHIP = 'Ship'
    METHOD_CHOICES = (
        (PICK_UP, 'Pick-up'),
        (DELIVERY, 'Delivery'),
        (MEET, 'Meet'),
        (SHIP, 'Ship'),
    )
    ACTIVE = 'Active'
    RETRACTED = 'Retracted'
    ACCEPTED = 'Accepted'
    STATUS_OPTIONS = (
        (ACTIVE, 'Active'),
        (RETRACTED, 'Retracted'),
        (ACCEPTED, 'Accepted')
    )

    item = models.ForeignKey(Items)
    buyer = models.ForeignKey(Account)
    sent_by_buyer = models.BooleanField(default=True)
    date_sent = models.DateTimeField(auto_now_add=True)
    proposed_price = models.DecimalField(
        max_digits=10, decimal_places=2, null=True)
    proposed_method = models.CharField(
        max_length=11, choices=METHOD_CHOICES, default=PICK_UP)
    status = models.CharField(
        max_length=11, choices=STATUS_OPTIONS, default=ACTIVE)

    def toDictionary(self):
        valuesDict = {
            'pk': self.pk,
            'item': self.item.toDictionary(),
            'buyer': self.buyer.toDictionary(),
            'sent_by_buyer': self.sent_by_buyer,
            'date_sent': self.date_sent.strftime('%Y-%m-%d %H:%M:%S'),
            'proposed_price': str(self.proposed_price),
            'proposed_method': self.proposed_method,
            'status': self.status
        }
        return valuesDict


class Sale(models.Model):
    item = models.OneToOneField(Items)
    acceptedOffer = models.ForeignKey(Offer)
    # Rating that the buyer gives the seller
    seller_rating = models.IntegerField(null=True)
    seller_rating_description = models.CharField(max_length=200, null=True)
    # Rating that the seller gives the buyer
    buyer_rating = models.IntegerField(null=True)
    buyer_rating_description = models.CharField(max_length=200, null=True)

    def toDictionary(self):
        valuesDict = {
            'item': self.item.toDictionary(),
            'acceptedOffer': self.acceptedOffer.toDictionary()
        }

        if(self.seller_rating is not None):
            valuesDict['seller_rating'] = self.seller_rating
            valuesDict[
                'seller_rating_description'] = self.seller_rating_description

        if(self.buyer_rating is not None):
            valuesDict['buyer_rating'] = self.buyer_rating
            valuesDict[
                'buyer_rating_description'] = self.buyer_rating_description

        return valuesDict
