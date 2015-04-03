from django.db import models

# Create your models here.
class Account(models.Model):
	email = models.CharField(max_length=200)
	password = models.CharField(max_length=20)
	facebookId = models.CharField(max_length=200)
	facebookAuthToken = models.CharField(max_length=200)
	twitterId = models.CharField(max_length=200)
	twitterAuthToken = models.CharField(max_length=200)
	displayName = models.CharField(max_length = 200)
	avatarImageUrl = models.CharField(max_length=200)
	sellerRating = models.DecimalField(max_digits = 2, decimal_places=1)
	itemsSold = models.IntegerField()
	buyerRating = models.DecimalField(max_digits = 2, decimal_places=1)
	itemsBought = models.IntegerField()

