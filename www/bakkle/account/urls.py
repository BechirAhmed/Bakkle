from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^facebook/$', views.facebook, name='facebook'),
    url(r'^(?P<account_id>[0-9]+)/$', views.detail, name='detail'),
    url(r'^device/(?P<device_id>[0-9]+)/$', views.device_detail, name='device_detail'),
    url(r'^device/register_push/$', views.device_register_push, name='device_register_push'),
    url(r'^device/(?P<device_id>[0-9]+)/notify/$', views.device_notify, name='device_notify'),
]
