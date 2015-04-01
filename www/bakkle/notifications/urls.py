from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^register/(?P<device_token>[a-z0-9]+)/$', views.register, name='register'),
    url(r'^notifyall/$', views.notifyall, name='notifyall'),
    url(r'^(?P<notification_id>[0-9]+)/$', views.detail, name='detail'),
]
