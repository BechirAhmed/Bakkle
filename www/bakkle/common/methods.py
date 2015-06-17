from chat.models import Message
from account.models import Account

def totalUnreadMessagesForAccount(account):
    buyerMessages = Message.objects.filter(chat__item__seller = account).filter(viewed_by_seller_time__isnull = True)
    sellerMessages = Message.objects.filter(chat__buyer = account).filter(viewed_by_buyer_time__isnull = True)

    unreadMessages = [];
    for message in buyerMessages:
        unreadMessages.append(message.toDictionary())
    for message in sellerMessages:
        unreadMessages.append(message.toDictionary())

    return unreadMessages;