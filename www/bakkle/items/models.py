import md5
import datetime

from django.db import models
from django.forms import ModelForm
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
    price = models.DecimalField(max_digits=7, decimal_places=2)
    tags = models.CharField(max_length=300)
    method = models.CharField(max_length=11, choices=METHOD_CHOICES, default=PICK_UP)
    status = models.CharField(max_length=11, choices = STATUS_OPTIONS, default=ACTIVE)
    post_date = models.DateTimeField(auto_now_add=True)
    times_reported = models.IntegerField(default=0)

    def __str__(self):
        # parse urls first into json string
        urls = self.image_urls.split(",")
        string_urls = "["
        for url in urls:
            if len(urls) == 1 or urls.index(url) == 1:
                string_urls = string_urls + "{\"url\": \"" + url + "\"}"
            else:
                string_urls = string_urls + ",{\"url\": \"" + url + "\"}"
        string_urls = string_urls + "]"

        # parse tags first into json string
        hash_tags = self.tags.split(",")
        string_tags = "["
        for tag in hash_tags:
            if len(hash_tags) == 1 or hash_tags.index(tag) == 0:
                string_tags = string_tags + "{\"tag\": \"" + tag + "\"}"
            else:
                string_tags = string_tags + ",{\"tag\": \"" + tag + "\"}"
        string_tags = string_tags + "]"

        # create items json
        return "{\"pk\": \"" + str(self.id) + "\", \"image_urls\": " + string_urls + ", \"title\": \"" + self.title + "\", \"description\": \"" + self.description + "\", \"location\": \"" + self.location + "\", \"seller\": \"" + str(self.seller.id) + "\", \"price\": \"" + str(self.price) + "\", \"tags\": " + string_tags + ", \"method\": \"" + self.method + "\", \"status\": \"" + self.status + "\", \"post_date\": \"" + self.post_date.strftime("%Y-%m-%d %H:%M:%S") + "\", \"times_reported\": \"" + str(self.times_reported) + "\"}"

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
    view_time = models.DateTimeField(auto_now = True)
    view_duration = models.DecimalField(max_digits = 10, decimal_places = 2)
    status = models.CharField(max_length=11, choices = STATUS_OPTIONS, default=ACTIVE)
    confirmed_price = models.DecimalField(max_digits = 7, decimal_places = 2)
    accepted_sale_price = models.BooleanField(default = False)
