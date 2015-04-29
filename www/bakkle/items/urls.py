from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^reset/$', views.reset, name='reset'),
    url(r'^feed/$', views.feed, name='feed'),
    url(r'^meh/$', views.meh, name='meh'),
    url(r'^want/$', views.want, name='want'),
    url(r'^hold/$', views.hold, name='hold'),
    url(r'^report/$', views.report, name='report'),
    url(r'^add_item/$', views.add_item, name='add_item'),
    url(r'^delete_item/$', views.delete_item, name='delete_item'),
    url(r'^sell_item/$', views.sell_item, name='sell_item'),
    # TODO: Remove the spam entry so that can no longer be reached once testing is complete
    url(r'^spam_item/$', views.spam_item, name='spam_item'),
    url(r'^get_seller_items/$', views.get_seller_items, name='get_seller_items'),
    url(r'^get_seller_transactions/$', views.get_seller_transactions, name='get_seller_transactions'),
    url(r'^get_buyers_trunk/$', views.get_buyers_trunk, name='get_buyers_trunk'), 
    url(r'^get_holding_pattern/$', views.get_holding_pattern, name='get_holding_pattern'),      
    url(r'^(?P<item_id>[0-9]+)/$', views.detail, name='detail'),

]

