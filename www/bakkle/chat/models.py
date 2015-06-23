from django.db import models
from account.models import Account
from items.models import Items

# Create your models here.
class Chat(models.Model):
    item = models.ForeignKey(Items)
    buyer = models.ForeignKey(Account)
    start_date = models.DateTimeField(auto_now_add=True)
    closed = models.BooleanField(default = False)

    class Meta:
        unique_together = ("item", "buyer")

    def toDictionary(self):
        valuesDict = {
            'pk': self.pk, 
            'item': self.item.toDictionary(), 
            'buyer': self.buyer.toDictionary(),
            'seller': self.item.seller.toDictionary(),
            'closed': self.closed,
            # 'last_message' : self.last_message.toDictionary(),
            'start_date': self.start_date.strftime('%Y-%m-%d %H:%M:%S') }

        messages = Message.objects.filter(chat = self).order_by('-date_sent')[:1];
        for message in messages:
            valuesDict['last_message'] = {
                'message': message.message,
                'date': message.date_sent.strftime('%Y-%m-%d %H:%M:%S')
            }
        return valuesDict

    def unreadMesages(self, account):
        if(self.buyer == account):
            return Message.objects.filter(chat = self).filter(viewed_by_buyer_time__isnull = True)
        else:
            return Message.objects.filter(chat = self).filter(viewed_by_seller_time__isnull = True)

class Message(models.Model):
    chat = models.ForeignKey(Chat)
    sent_by_buyer = models.BooleanField(default = True)
    date_sent = models.DateTimeField(auto_now_add=True)
    viewed_by_buyer_time = models.DateTimeField(null = True, auto_now = False)
    viewed_by_seller_time = models.DateTimeField(null = True, auto_now = False)
    message = models.CharField(max_length=500)
    proposed_price = models.DecimalField(max_digits = 10, decimal_places=2, null = True)

    def toDictionary(self):
        valuesDict = {
            'pk': self.pk,
            'sent_by_buyer': self.sent_by_buyer,
            'date_sent': self.date_sent.strftime('%Y-%m-%d %H:%M:%S'),
            'message': self.message
        }

        if(self.viewed_by_buyer_time is not None):
            valuesDict['viewed_by_buyer_time'] = self.viewed_by_buyer_time.strftime('%Y-%m-%d %H:%M:%S')
        if(self.viewed_by_seller_time is not None):
            valuesDict['viewed_by_seller_time'] = self.viewed_by_seller_time.strftime('%Y-%m-%d %H:%M:%S')
        return valuesDict
    