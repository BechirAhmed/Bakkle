from django.db import models

class Items(models.Model):
    PICK_UP = 'Pick-up'
    DELIVERY = 'Delivery'
    METHOD_CHOICES = (
        (PICK_UP, 'Pick-up'),
        (DELIVERY, 'Delivery'),
    )
    post_date = models.DateTimeField('date posted')
    expire_date = models.DateTimeField('expire date')
    title = models.CharField(max_length=200)
    description = models.CharField(max_length=2000)
    #image-url-list
    price = models.IntegerField()
    #use django-location-field?
    method = models.CharField(max_length=2,
                              choices=METHOD_CHOICES,
                              default=PICK_UP)
