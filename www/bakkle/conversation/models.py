from django.db import models
from account.models import Account
from items.models import Items

# Create your models here.
class Conversation(models.Model):
    item_id = models.ForeignKey(Items)
    buyer_id = models.ForeignKey(Account)
    deleted = models.BooleanField(default = False)
    start_date = models.DateTimeField(auto_now_add=True)

class Message(models.Model):
    conversation_id = models.ForeignKey(Conversation)
    buyer_seller_flag = models.BooleanField(default = True)
    date_sent = models.DateTimeField(auto_now_add=True)
    viewed = models.DateTimeField(null = True, auto_now = False)
    message = models.CharField(max_length=500)
    url = models.CharField(max_length=500)
    proposed_price = models.DecimalField(max_digits = 7, decimal_places=2)