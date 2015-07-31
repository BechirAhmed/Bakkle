import md5
import datetime
from django.utils import timezone

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
    # use django-location-field?
    # location = models.CharField(max_length=25)
    latitude = models.DecimalField(
        max_digits=5, decimal_places=2, default=37.47)
    longitude = models.DecimalField(
        max_digits=5, decimal_places=2, default=122.25)
    seller = models.ForeignKey(Account)
    price = models.DecimalField(max_digits=11, decimal_places=2)
    tags = models.CharField(max_length=300)
    method = models.CharField(
        max_length=11, choices=METHOD_CHOICES, default=PICK_UP)
    status = models.CharField(
        max_length=11, choices=STATUS_OPTIONS, default=ACTIVE)
    post_date = models.DateTimeField(auto_now_add=True)
    times_reported = models.IntegerField(default=0)

    def toDictionary(self):
        images = []
        hashtags = []

        urls = self.image_urls.split(",")
        for url in urls:
            if url != "" and url != " ":
                images.append(url)

        valuesDict = {'pk': self.pk,
                      'description': self.description,
                      'seller': self.seller.toDictionary(),
                      'image_urls': images,
                      'tags': self.tags,
                      'title': self.title,
                      'location': str(self.latitude) + "," + str(self.longitude),
                      'price': str(self.price),
                      'method': self.method,
                      'status': self.status,
                      'post_date': self.post_date.strftime("%Y-%m-%d %H:%M:%S %Z")}
        return valuesDict

from purchase.models import Sale


class BuyerItem(models.Model):
    ACTIVE = 'Active'
    MEH = 'Meh'
    HOLD = 'Hold'
    WANT = 'Want'
    REPORT = 'Report'
    NEGOTIATING = 'Negotiating'
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
        (NEGOTIATING, 'Negotiating'),
        (PENDING, 'Pending'),
        (SOLD, 'Sold'),
        (SOLD_TO, 'Sold To'),
        (MY_ITEM, 'My Item')
    )
    buyer = models.ForeignKey(Account)
    item = models.ForeignKey(Items)
    view_time = models.DateTimeField(auto_now=True)
    view_duration = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(
        max_length=11, choices=STATUS_OPTIONS, default=ACTIVE)
    confirmed_price = models.DecimalField(max_digits=7, decimal_places=2)
    accepted_sale_price = models.BooleanField(default=False)
    sale = models.ForeignKey(Sale, null=True)
    message = models.CharField(max_length=500, null=True)

    class Meta:
        unique_together = ("buyer", "item")

    def toDictionary(self):
        valuesDict = {
            'pk': self.pk,
            'view_time': self.view_time.strftime("%Y-%m-%d %H:%M:%S %Z"),
            'view_duration': str(self.view_duration),
            'status': self.status,
            'confirmed_price': str(self.confirmed_price),
            'accepted_sale_price': self.accepted_sale_price,
            'item': self.item.toDictionary(),
            'buyer': self.buyer.toDictionary()}

        if self.sale is not None:
            valuesDict['sale'] = self.sale.toDictionary()
        else:
            valuesDict['sale'] = None

        if self.message is not None:
            valuesDict['message'] = self.message
        else:
            valuesDict['message'] = None

        return valuesDict
