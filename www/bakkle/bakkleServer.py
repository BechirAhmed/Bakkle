import os
import sys

# import base tornado libraries
from tornado import ioloop
from tornado import web
from tornado import websocket

# django settings must be called before importing models
import django
from django.conf import settings
from common.sysVars import getDATABASES;

settings.configure(DATABASES=getDATABASES())

from django.db import models

# import handlers
import requestHandlers as rootRequestHandlers 
import chat.requestHandlers as chatRequestHandlers 

class Message(models.Model):
    """
    Message is the django model class. In order to use it you will need to
    create the database manually.

    sqlite> CREATE TABLE message (id integer primary key, subject varchar(30),
            content varchar(250));
    sqlite> insert into message values(1, 'subject', 'cool stuff');
    sqlite> SELECT * from message;
    """
    
    subject = models.CharField(max_length=30)
    content = models.TextField(max_length=250)

    class Meta:
        app_label = 'dj'
        db_table = 'message'
    def __unicode__(self):
        return self.subject + "--" + self.content


class ListMessagesHandler(web.RequestHandler):
    def get(self):
        # print("Args: " + str(self.request.arguments));
        # print("Query: " + str(self.request.query));
        # print("Headers: " + str(self.request.headers));
        # print("Body: " + str(self.request.body));
        print(self.request.headers['User-Agent'])
        messages = Message.objects.all()
        self.render("templates/index.html", title="My title",
                    messages=messages)
            
app = web.Application([
    (r"/", ListMessagesHandler),
    # (r"/ws/", rootRequestHandlers.BaseWSHandler),
    (r"/ws/", chatRequestHandlers.ChatWSHandler),
    # (r"/items/[0-9]+/detail", itemsRequestHandlers.ItemRequestHandler),
    # (r"/items/[0-9]+/detail", itemsRequestHandlers.ItemRequestHandler),
])

# Start the server
if __name__ == "__main__":
    # os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'bakkle.settings')
    django.setup()

    app.listen(8080)
    ioloop.IOLoop.instance().start()
