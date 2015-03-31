from django.db import models

class PushRegistrations(models.Model):
	user_id = models.CharField(max_length=200)
	device_token = models.CharField(max_length=200)
	subscribe_date = models.DateTimeField('date subscribed')
	enabled = models.IntegerField(default=1)
	def __str__(self):
		return "User: %s".format(user_id)

	def isActive(self):
		return self.enabled==1

