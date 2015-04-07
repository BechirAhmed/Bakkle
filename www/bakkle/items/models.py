from django.db import models
from account.models import Account

class Items(models.Model):
    PICK_UP = 'Pick-up'
    DELIVERY = 'Delivery'
    METHOD_CHOICES = (
        (PICK_UP, 'Pick-up'),
        (DELIVERY, 'Delivery'),
    )
    ACTIVE = 'Active'
    PENDING = 'Pending'
    SOLD = 'Sold'
    EXPIRED = 'Expired'
    SPAM = 'Spam'
    DELETED = 'Deleted'
    STATUS_OPTIONS = (
        (ACTIVE, 'Active'),
        (PENDING, 'Pending'),
        (SOLD, 'Sold'),
        (EXPIRED, 'Expired'),
        (SPAM, 'Spam'),
        (DELETED, 'Deleted'),
    )
    imageUrls = models.CharField(max_length=1000)
    title = models.CharField(max_length=200)
    description = models.CharField(max_length=4000)
    #use django-location-field?
    location = models.CharField(max_length=11)
    seller = models.ForeignKey(Account)
    price = models.DecimalField(max_digits=7, decimal_places=2)
    tags = models.CharField(max_length=300)
    method = models.CharField(max_length=11, choices=METHOD_CHOICES, default=PICK_UP)
    status = models.CharField(max_length=11, choices = STATUS_OPTIONS, default=ACTIVE)
    postDate = models.DateTimeField(auto_now_add=True)
    timesReported = models.IntegerField(default=0)

class BuyerItem(models.Model):
    ACTIVE = 'Active'
    MEH = 'Meh'
    HOLD = 'Hold'
    WANT = 'Want'
    REPORT = 'Report'
    NEGOCIATING = 'Negociating'
    PENDING = 'Pending'
    SOLD = 'Sold'
    STATUS_OPTIONS = (
        (ACTIVE, 'Active'),
        (MEH, 'Meh'),
        (HOLD, 'Hold'),
        (WANT, 'Want'),
        (REPORT, 'Report'),
        (NEGOCIATING, 'Negociating'),
        (PENDING, 'Pending'),
        (SOLD, 'Sold'),
    )
    buyer = models.ForeignKey(Account)
    item = models.ForeignKey(Items)
    viewTime = models.DateTimeField(auto_now = True)
    status = models.CharField(max_length=11, choices = STATUS_OPTIONS, default=ACTIVE)
    confirmedPrice = models.DecimalField(max_digits = 7, decimal_places = 2)



