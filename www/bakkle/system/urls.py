from django.conf.urls import url

from . import views

urlpatterns = [
    #url(r'^$', views.index, name='index'),
    url(r'^restart/$', views.restart, name='restart'),
    url(r'^update/$',  views.update,  name='update'),
    url(r'^health/$',  views.health,  name='health'),
    url(r'^version/$', views.version, name='version'),
]
