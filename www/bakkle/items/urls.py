from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^reset/$', views.reset, name='reset'),
    url(r'^reset_items/$', views.reset_items, name='reset_items'),
    url(r'^feed/$', views.feed, name='feed'),
    url(r'^meh/$', views.meh, name='meh'),
    url(r'^want/$', views.want, name='want'),
    url(r'^hold/$', views.hold, name='hold'),
    url(r'^sold/$', views.sold, name='hold'),
    url(r'^report/$', views.report, name='report'),
    url(r'^add_item/$', views.add_item, name='add_item'),
    url(r'^delete_item/$', views.delete_item, name='delete_item'),
    #url(r'^sell_item/$', views.sell_item, name='sell_item'),
    # TODO: Remove the spam entry so that can no longer be reached once testing is complete
    url(r'^spam_item/$', views.spam_item, name='spam_item'),
    url(r'^get_seller_items/$', views.get_seller_items, name='get_seller_items'),
    url(r'^get_seller_transactions/$', views.get_seller_transactions, name='get_seller_transactions'),
    url(r'^get_buyers_trunk/$', views.get_buyers_trunk, name='get_buyers_trunk'),
    url(r'^get_holding_pattern/$', views.get_holding_pattern, name='get_holding_pattern'),
    url(r'^get_buyer_transactions/$', views.get_buyer_transactions, name='get_buyer_transactions'),
    url(r'^get_delivery_methods/$', views.get_delivery_methods, name='get_delivery_methods'),
    url(r'^i(?P<item_id>[0-9]+)/$', views.public_detail, name='public_detail'),
    url(r'^(?P<item_id>[0-9]+)/$', views.detail, name='detail'),
    url(r'^(?P<item_id>[0-9]+)/spam/$', views.mark_as_spam, name='mark_as_spam'),
    url(r'^(?P<item_id>[0-9]+)/delete/$', views.mark_as_deleted, name='mark_as_deleted'),

]
