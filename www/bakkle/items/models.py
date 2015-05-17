import md5
import datetime

from django.db import models
from account.models import Account

class Items(models.Model):
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
    image_urls = models.CharField(max_length=1000)
    title = models.CharField(max_length=200)
    description = models.CharField(max_length=4000)
    #use django-location-field?
    location = models.CharField(max_length=11)
    seller = models.ForeignKey(Account)
    price = models.DecimalField(max_digits=11, decimal_places=2)
    tags = models.CharField(max_length=300)
    method = models.CharField(max_length=11, choices=METHOD_CHOICES, default=PICK_UP)
    status = models.CharField(max_length=11, choices = STATUS_OPTIONS, default=ACTIVE)
    post_date = models.DateTimeField(auto_now_add=True)
    times_reported = models.IntegerField(default=0)

class BuyerItem(models.Model):
    ACTIVE = 'Active'
    MEH = 'Meh'
    HOLD = 'Hold'
    WANT = 'Want'
    REPORT = 'Report'
    NEGOCIATING = 'Negociating'
    PENDING = 'Pending'
    SOLD = 'Sold'
    SOLD_TO = 'Sold To'
    MY_ITEM = 'My Item'
    STATUS_OPTIONS = (
        (ACTIVE, 'Active'),
        (MEH, 'Meh'),
        (HOLD, 'Hold'),
        (WANT, 'Want'),
        (REPORT, 'Report'),
        (NEGOCIATING, 'Negociating'),
        (PENDING, 'Pending'),
        (SOLD, 'Sold'),
        (SOLD_TO, 'Sold To'),
        (MY_ITEM, 'My Item')
    )
    buyer = models.ForeignKey(Account)
    item = models.ForeignKey(Items)
    view_time = models.DateTimeField(auto_now = True)
    view_duration = models.DecimalField(max_digits = 10, decimal_places = 2)
    status = models.CharField(max_length=11, choices = STATUS_OPTIONS, default=ACTIVE)
    confirmed_price = models.DecimalField(max_digits = 7, decimal_places = 2)
    accepted_sale_price = models.BooleanField(default = False)

    class Meta:
        unique_together = ("buyer", "item")