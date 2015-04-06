from django.db import models

# Create your models here.
class Account(models.Model):
	email = models.CharField(max_length=200, unique = True)
	password = models.CharField(max_length=20)
	facebookId = models.CharField(max_length=200, unique = True)
	twitterId = models.CharField(max_length=200)
	displayName = models.CharField(max_length = 200)
	avatarImageUrl = models.CharField(max_length=200)
	sellerRating = models.DecimalField(max_digits = 2, decimal_places=1)
	itemsSold = models.IntegerField()
	buyerRating = models.DecimalField(max_digits = 2, decimal_places=1)
	itemsBought = models.IntegerField()

class Device(models.Model):
	account_id = models.ForeignKey(Account)
	dateAdded = models.DateTimeField(auto_now_add = True)
	lastSeenDate = models.DateTimeField(auto_now = True)
	apnsToken = models.CharField(max_length=64)
	ipAddress = models.CharField(max_length=15)
	uuid = models.CharField(max_length=36)
	notificationsEnabled = models.BooleanField()

	class Meta:
		unique_together = ("account_id", "uuid")