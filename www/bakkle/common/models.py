from django.db import models
# from account.models import Account
# from items.models import Items

# # Create your models here.
# class Conversation(models.Model):
#     item = models.ForeignKey(Items)
#     buyer = models.ForeignKey(Account)
#     deleted_seller = models.BooleanField(default = False)
#     deleted_buyer = models.BooleanField(default = False)
#     start_date = models.DateTimeField(auto_now_add=True)

#     class Meta:
#         unique_together = ("item", "buyer")

# class Message(models.Model):
#     conversation = models.ForeignKey(Conversation)
#     buyer_seller_flag = models.BooleanField(default = True)
#     date_sent = models.DateTimeField(auto_now_add=True)
#     viewed = models.DateTimeField(null = True, auto_now = False)
#     message = models.CharField(max_length=500)
#     url = models.CharField(max_length=500)
#     proposed_price = models.DecimalField(max_digits = 11, decimal_places=2, null = True)
#     deleted_seller = models.BooleanField(default = False)
#     deleted_buyer = models.BooleanField(default = False)