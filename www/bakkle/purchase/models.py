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


    def toDictionary(self):
        valuesDict = {
            'item': self.item.toDictionary(),
            'acceptedOffer': self.acceptedOffer.toDictionary()
        }
        return valuesDict
