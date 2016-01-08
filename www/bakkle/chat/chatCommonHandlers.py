
from django.db.models import Q
from account.models import Account
from account.models import Device
from models import Chat
from models import Message
from items.models import Items
from purchase.models import Offer
from common.methods import getNumUnreadChatsForAccount
from common.decorators import run_async

from decimal import *

# import baseWSHandlers

import datetime
import logging

def startChat(itemId, buyerId):
    try:
        item = Items.objects.get(pk=itemId)
        buyer = Account.objects.get(pk=buyerId)

        if(item.seller == buyer):
            return {'success': 0, 'error': 'Cannot start chat session with yourself.'}

        chat = Chat.objects.get_or_create(
            item=item,
            buyer=buyer)[0]

    except Items.DoesNotExist:
        return {'success': 0, 'error': 'Invalid itemId provided'}
    except Account.DoesNotExist:
        return {'success': 0, 'error': 'Invalid buyerId provided'}

    return {'success': 1, 'chatId': chat.pk}


def getChatIds(itemId, sellerId):

    try:
        item = Items.objects.get(pk=itemId)
        seller = Account.objects.get(pk=sellerId)

    except Items.DoesNotExist:
        return {'success': 0, 'error': 'Invalid itemId provided'}
    except Account.DoesNotExist:
        return {'success': 0, 'error': 'Invalid sellerId provided'}

    try:
        chats = Chat.objects.filter(item=item)

    except Chat.DoesNotExist:
        chats = None

    openChats = []

    for chat in chats:
        openChats.append(chat.toDictionary())

    return {'success': 1, 'chats': openChats}


def sendChatMessage(clients, chatId, senderId, message, offerPrice, offerMethod):

    try:
        message = message.strip()
        chat = Chat.objects.get(pk=chatId)
        sender = Account.objects.get(pk=senderId)
        sentByBuyer = (sender == chat.buyer)

        offer = None
        if (offerPrice is not None and offerPrice != "") and (offerMethod is not None and offerMethod != ""):
            try:
                offerPrice = Decimal(offerPrice)
            except ValueError:
                return {"status": 0, "error": "Price was not a valid decimal."}

            Offer.objects.filter(item=chat.item).filter(status='Active').filter(
                sent_by_buyer=sentByBuyer).update(status='Retracted')

            offer = Offer.objects.create(
                item=chat.item,
                buyer=chat.buyer,
                sent_by_buyer=sentByBuyer,
                proposed_price=offerPrice,
                proposed_method=offerMethod
            )

    except KeyError as e:
        return {'success': 0, 'error': 'Missing parameter ' + str(e)}
    except Chat.DoesNotExist:
        return {'success': 0, 'error': 'Invalid chatId provided'}
    except Account.DoesNotExist:
        return {'success': 0, 'error': 'Invalid senderId provided'}

    if(sender != chat.item.seller and sender != chat.buyer):
        return {'success': 0, 'error': 'Invalid chatId provided - user not involved in specified chat.'}

    newMessage = Message.objects.create(
        chat=chat, sent_by_buyer=sentByBuyer, message=message)
    newMessage.date_sent = datetime.datetime.now()
    if (offer is not None):
        newMessage.offer = offer
    newMessage.save()

    chat.hasUnreadBuyer = not sentByBuyer
    chat.hasUnreadSeller = sentByBuyer
    chat.save()

    logging.info("Chat item={} seller={} buyer={} senderid={}".format(chat.item.id, chat.item.seller.id, chat.buyer.id, senderId))

    # Find devices owned by seller
    if(sender != chat.item.seller):
      devices = Device.objects.filter(account_id=chat.item.seller)
      sellerNumUnreadChats = getNumUnreadChatsForAccount(chat.item.seller.pk)
      for device in devices:
        device.send_notification(
            message,
            sellerNumUnreadChats,
            "Bakkle_Notification_new.m4r",
            {'chat_id': chat.id, 'item_id':chat.item.id, 'seller_id':chat.item.seller.id, 'buyer_id':chat.buyer.id})
        
    # Find devices owned by BUYER
    if(sender != chat.buyer):
      devices = Device.objects.filter(account_id=chat.buyer)
      buyerNumUnreadChats = getNumUnreadChatsForAccount(chat.buyer.pk)
      for device in devices:
        device.send_notification(
            message,
            buyerNumUnreadChats,
            "Bakkle_Notification_new.m4r",
            {'chat_id': chat.id, 'item_id':chat.item.id, 'seller_id':chat.item.seller.id, 'buyer_id':chat.buyer.id})


    if(message is not None and message != ""):
        if(chat.item.seller.pk in clients):
            for uuid in clients[chat.item.seller.pk]:
                clients[chat.item.seller.pk][uuid].write_message(
                    {'success': 1, 'messageOrigin': senderId, 'notificationType': 'newMessage', 'message': newMessage.toDictionary()})

        if(chat.buyer.pk in clients):
            for uuid in clients[chat.buyer.pk]:
                clients[chat.buyer.pk][uuid].write_message(
                    {'success': 1, 'messageOrigin': senderId, 'notificationType': 'newMessage', 'message': newMessage.toDictionary()})

    elif (offerPrice is not None and offerPrice != "") and (offerMethod is not None and offerMethod != ""):
        if(chat.item.seller.pk in clients):
            for uuid in clients[chat.item.seller.pk]:
                clients[chat.item.seller.pk][uuid].write_message(
                    {'success': 1, 'messageOrigin': senderId, 'notificationType': 'newOffer', 'message': newMessage.toDictionary()})

        if(chat.buyer.pk in clients):
            for uuid in clients[chat.buyer.pk]:
                clients[chat.buyer.pk][uuid].write_message(
                    {'success': 1, 'messageOrigin': senderId, 'notificationType': 'newOffer', 'message': newMessage.toDictionary()})

    return {'success': 1}


def getMessagesForChat(chatId, requesterId):
    try:

        chat = Chat.objects.get(pk=chatId)
        requester = Account.objects.get(pk=requesterId)

        if(requester != chat.item.seller and requester != chat.buyer):
            return {'success': 0, 'error': 'Invalid chatId provided - user not involved in specified chat.'}

        messages = Message.objects.filter(chat=chat).order_by('-date_sent')

    except KeyError as e:
        return {'success': 0, 'error': 'Missing parameter ' + str(e)}
    except Chat.DoesNotExist:
        return {'success': 0, 'error': 'Invalid chatId provided'}
    except Account.DoesNotExist:
        return {'success': 0, 'error': 'Invalid senderId provided'}

    userMessages = []

    for message in messages:
        userMessages.append(message.toDictionary())

    if (requesterId == chat.buyer.pk):
        chat.hasUnreadBuyer = False
    elif (requesterId == chat.item.seller.pk):
        chat.hasUnreadSeller = False
    chat.save()

    return {'success': 1, 'messages': userMessages}
