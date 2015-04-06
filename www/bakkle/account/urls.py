from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^(?P<account_id>[a-z0-9]+)/$', views.detail, name='detail'),
    
    url(r'^facebook/$', views.facebook, name='facebook'),
    url(r'^device/$', views.device, name='device'),
    url(r'^device/detail$', views.device_detail, name='device_detail'),
    url(r'^device/register$', views.device_register, name='device_register'),
    url(r'^device/(P<device_id>[0-9]+)/notify/$', views.device_notify, name='device_notify'),
]
