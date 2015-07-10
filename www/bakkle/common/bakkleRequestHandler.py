from tornado import web
import json
from account.models import Device


class bakkleRequestHandler(web.RequestHandler):

    def authenticate(self):
        authToken = self.getArgument("auth_token")
        uuid = self.getArgument("uuid")

        try:
            Device.objects.get(auth_token=authToken, uuid=uuid)
        except Device.DoesNotExist:
            return False

        return True

    def getArgument(self, key, default=None):

        try:
            queryArgument = self.get_argument(key)
        except web.MissingArgumentError:
            if default is not None:
                return default
            else:
                raise QueryArgumentError(
                    "No values for key '" + str(key) + "' found")

        # if(queryArgument is None or queryArgument.strip() == ""):
        #     raise QueryArgumentError(
        #         "No values for key '" + str(key) + "' found")
        #     return self.writeJSON({"success": 0,
        #                            "message": "Invalid value for key '"
        #                            + str(key) + "' found"})

        return queryArgument

        # handle error cases - no value given, or too many values given.
        # elif (len(queryArgument) == 0):
        #     raise QueryArgumentError(
        #         "No values for key '" + str(key) + "' found")
        # else:
        #     raise QueryArgumentError(
        #         "Multiple values for key '" + str(key) + "' found")

    def getUser(self):
        authToken = self.getArgument("auth_token")

        if("_" not in authToken):
            raise QueryArgumentError(
                "Invalid auth token format")

        return authToken.split('_')[1]

    def writeJSON(self, response):
        # print(json.dumps(response))
        self.write(response)
        # self.finish()

    def getIP(self):
        x_real_ip = self.request.headers.get("X-Real-IP")
        return self.request.remote_ip if not x_real_ip else x_real_ip


class QueryArgumentError(Exception):

    def __init__(self, message):
        self.message = message

    def __str__(self):
        return repr(self.message)
