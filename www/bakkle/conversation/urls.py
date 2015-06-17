from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^delete_conversation/$', views.delete_conversation, name='delete_conversation'),
    url(r'^delete_message/$', views.delete_message, name='delete_message'),
    url(r'^send_message/$', views.send_message, name='send_message'),
    url(r'^view_message/$', views.view_message, name='view_message'),
    url(r'^get_conversations/$', views.get_conversations, name='get_conversations'),
    url(r'^get_messages/$', views.get_messages, name='get_messages'),
    url(r'^(?P<conversation_id>[0-9]+)/$', views.detail, name='detail'),

]
