
from tornado import web
from tornado import websocket

class EchoWebSocket(websocket.WebSocketHandler):
    #ignore origin headers
    def check_origin(self, origin):
        return True

    #on websocket open, send settings bundle
    def open(self):
        print("WebSocket opened")
        self.write_message(u"Welcome to the websocket handler!")

    #on receipt of message, respond accordingly.
    def on_message(self, message):
        self.write_message(u"You said: " + message)

    def on_close(self):
        print("WebSocket closed")

class ItemRequestHandler(web.RequestHandler):
    def get(self):

        print("Received request")

        views.index(self)

        # print("Args: " + str(self.request.arguments));
        # print("Query: " + str(self.request.query));
        # print("Headers: " + str(self.request.headers));
        # print("Body: " + str(self.request.body));
        self.write("Welcome");
        # self.render("templates/index.html", title="My title",
        #             messages=messages)


    def post(self):
        print(self.request.headers['User-Agent'])
        messages = Message.objects.all()
        # self.render("templates/index.html", title="My title",
        #             messages=messages)
