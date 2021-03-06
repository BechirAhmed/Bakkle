from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^settings/$', views.settings, name='settings'),
    url(r'^dashboard/$', views.dashboard, name='index'),
    url(r'^login_facebook/$', views.login_facebook, name='login_facebook'),
    url(r'^logout/$', views.logout, name='logout'),
    url(r'^facebook/$', views.facebook, name='facebook'),
    url(r'^(?P<account_id>[0-9]+)/$', views.detail, name='detail'),
    url(r'^reset/(?P<account_id>[0-9]+)/$', views.reset, name='reset'),
    url(r'^device/notify_all/$', views.device_notify_all_new_item, name='device_notify_all_new_item'),
    url(r'^device/(?P<device_id>[0-9]+)/$', views.device_detail, name='device_detail'),
    url(r'^device/register_push/$', views.device_register_push, name='device_register_push'),
    url(r'^device/(?P<account_id>[0-9]+)/notify_all/$', views.device_notify_all, name='device_notify_all'),
    url(r'^device/(?P<device_id>[0-9]+)/notify/$', views.device_notify, name='device_notify'),
]
