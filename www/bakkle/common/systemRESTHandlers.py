from common.bakkleRequestHandler import bakkleRequestHandler
from common.bakkleRequestHandler import QueryArgumentError
from common.decorators import run_async
from tornado.web import asynchronous
import logging



class statusHandler(bakkleRequestHandler):

    def get(self):
        self.writeJSON(
                    {'success': 1, 'message': 'Server operational'})
        return


