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
    url(r'^(?P<item_id>[0-9]+)/$', views.detail, name='detail'),
]

