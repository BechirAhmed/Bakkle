from chat.models import Chat


def getNumUnreadChatsForAccount(accountId):

    buyerChats = Chat.objects.filter(
        buyer__pk=accountId
    ).filter(hasUnreadBuyer=True)
    sellerChats = Chat.objects.filter(
        item__seller__pk=accountId
    ).filter(hasUnreadSeller=True)

    return len(buyerChats) + len(sellerChats)
