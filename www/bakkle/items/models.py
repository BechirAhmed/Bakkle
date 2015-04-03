from django.db import models

class Items(models.Model):
    PICK_UP = 'Pick-up'
    DELIVERY = 'Delivery'
    METHOD_CHOICES = (
        (PICK_UP, 'Pick-up'),
        (DELIVERY, 'Delivery'),
    )
    imageUrl = models.CharField(max_length=1000)
    title = models.CharField(max_length=200)
    description = models.CharField(max_length=4000)
    #use django-location-field?
    location = models.CharField(max_length=11)
    seller = models.ForeignKey(Account)
    price = models.IntegerField()
    post_date = models.DateTimeField('date posted')
    expire_date = models.DateTimeField('expire date')
    #image-url-list
    method = models.CharField(max_length=2,
                              choices=METHOD_CHOICES,
                              default=PICK_UP)
