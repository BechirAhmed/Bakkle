from django.db import models

import time

# Create your models here.
class Timing(models.Model):
    datetime = models.DateTimeField(auto_now=True)
    user = models.IntegerField()
    func = models.CharField(max_length=50)
    time = models.IntegerField()
    args = models.CharField(max_length=500)

