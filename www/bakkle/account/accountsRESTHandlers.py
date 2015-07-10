from common.bakkleRequestHandler import bakkleRequestHandler
from common.bakkleRequestHandler import QueryArgumentError


import accountsCommonHandlers


class loginFacebookHandler(bakkleRequestHandler):

    def post(self):

        print("loginFacebook")
        # TODO: Handle location
        # Get the rest of the necessary params from the request
        try:
            user_id = self.getArgument('user_id')
            device_uuid = self.getArgument('device_uuid')
            user_location = self.getArgument('user_location')
            app_version = self.getArgument('app_version')
            is_ios = self.getArgument('is_ios', True)
            client_ip = self.getIP()
            app_flavor = self.getArgument("flavor", 0)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.login_facebook(user_id,
                                                        device_uuid,
                                                        user_location,
                                                        app_version,
                                                        is_ios,
                                                        client_ip,
                                                        app_flavor)

        self.writeJSON(respObj)


class setDescriptionHandler(bakkleRequestHandler):

    def post(self):

        print("loginFacebook")
        # TODO: Handle location
        # Get the rest of the necessary params from the request
        try:
            user_id = self.getUser()
            description = self.getArgument('description')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.set_description(user_id,
                                                         description)

        self.writeJSON(respObj)


class getAccountHandler(bakkleRequestHandler):

    def post(self):

        print("loginFacebook")
        # TODO: Handle location
        # Get the rest of the necessary params from the request
        try:
            accountId = self.getArgument('accountId')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.get_account(accountId)

        self.writeJSON(respObj)


class logoutHandler(bakkleRequestHandler):

    def post(self):

        print("Logout")
        # TODO: Handle location
        # Get the rest of the necessary params from the request
        try:
            auth_token = self.getArgument('auth_token')
            device_uuid = self.getArgument('device_uuid')
            client_ip = self.getIP()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.logout(auth_token,
                                                device_uuid,
                                                client_ip)

        self.writeJSON(respObj)


class facebookHandler(bakkleRequestHandler):

    def post(self):

        try:
            facebook_id = self.getArgument('user_id')
            display_name = self.getArgument('name')
            email = self.getArgument('email')
            device_uuid = self.getArgument('device_uuid')
            app_flavor = self.getArgument('flavor', 0)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.facebook(facebook_id,
                                                  display_name,
                                                  email,
                                                  device_uuid,
                                                  app_flavor)

        self.writeJSON(respObj)


class deviceRegisterPushHandler(bakkleRequestHandler):

    def post(self):

        try:
            account_id = self.getUser()
            device_uuid = self.getArgument('device_uuid')
            device_token = self.getArgument('device_token')
            client_ip = self.getIP()
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.device_register_push(
            account_id,
            device_uuid,
            device_token,
            client_ip)

        self.writeJSON(respObj)
