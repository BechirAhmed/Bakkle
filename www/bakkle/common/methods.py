from chat.models import Chat
from account.models import Account
from django.db.models import Q


def getNumUnreadChatsForAccount(account):

    chats = Chat.objects.filter(
        Q(buyer__pk=account) |
        Q(item__seller__pk=account)
    ).filter(hasUnread=True)

    return len(chats)
