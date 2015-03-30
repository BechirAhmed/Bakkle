from django.db import models

# Create your models here.
class Item(models.Model):
    uuid = models.CharField(max_length=20)
    post_date = models.DateTimeField('date posted')

