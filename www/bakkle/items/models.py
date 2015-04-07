from django.db import models
from account.models import Account

class Items(models.Model):
    PICK_UP = 0
    DELIVERY = 1
    METHOD_CHOICES = (
        (PICK_UP, 'Pick-up'),
        (DELIVERY, 'Delivery'),
    )
    ACTIVE = 0
    PENDING = 1
    SOLD = 2
    EXPIRED = 3
    SPAM = 4
    DELETED = 5
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
    method = models.IntegerField(choices=METHOD_CHOICES, default=PICK_UP)
    status = models.IntegerField(choices = STATUS_OPTIONS, default=ACTIVE)
    postDate = models.DateTimeField(auto_now_add=True)
    timesReported = models.IntegerField(default=0)

class BuyerItem(models.Model):
    ACTIVE = 1
    MEH = 2
    HOLD = 3
    WANT = 4
    REPORT = 5
    NEGOCIATING = 6
    PENDING = 7
    SOLD = 8
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
    status = models.IntegerField(choices = STATUS_OPTIONS, default=ACTIVE)



