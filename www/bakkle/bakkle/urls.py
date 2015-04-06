from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'bakkle.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^account/', include('account.urls', namespace="account")),
    url(r'^items/', include('items.urls', namespace="items")),
    url(r'^notifications/', include('notifications.urls', namespace="notifications")),
    url(r'^admin/', include(admin.site.urls)),
)
