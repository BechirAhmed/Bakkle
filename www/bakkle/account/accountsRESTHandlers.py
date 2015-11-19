from common.bakkleRequestHandler import bakkleRequestHandler
from common.bakkleRequestHandler import QueryArgumentError
from common.decorators import run_async
from tornado.web import asynchronous
import logging

import accountsCommonHandlers


class indexHandler(bakkleRequestHandler):

    @asynchronous
    def get(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):

        account_list = accountsCommonHandlers.index()

        self.render('templates/account/index.html',
                    title="account",
                    account_list=account_list
                    )
        return


class accountDashboardHandler(bakkleRequestHandler):

    @asynchronous
    def get(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):

        context = accountsCommonHandlers.dashboard()

        self.render('templates/account/dashboard.html',
                    title="account",
                    register_users=context['register_users'],
                    active_users=context['active_users'],
                    total_items=context['total_items'],
                    total_sold=context['total_sold'],
                    total_expired=context['total_expired'],
                    total_deleted=context['total_deleted'],
                    total_spam=context['total_spam'],
                    total_pending=context['total_pending']
                    )
        return


class accountDetailHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, account_id):
        self.asyncHelper(account_id)

    @run_async
    def asyncHelper(self, account_id):

        context = accountsCommonHandlers.detail(account_id)

        self.render('templates/account/detail.html',
                    title="account",
                    account=context['account'],
                    devices=context['devices'],
                    items=context['items'],
                    selling=context['selling'],
                    item_count=context['item_count'],
                    items_sold=context['items_sold'],
                    items_viewed=context['items_viewed']
                    )
        return


class deviceDetailHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, device_id):
        self.asyncHelper(device_id)

    @run_async
    def asyncHelper(self, device_id):

        device = accountsCommonHandlers.device_detail(device_id)

        self.render('templates/account/device_detail.html',
                    title="device",
                    device=device
                    )
        return


class deviceNotifyHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, device_id):
        self.asyncHelper(device_id)

    @run_async
    def asyncHelper(self, device_id):

        respObj = accountsCommonHandlers.device_notify(device_id)

        self.writeJSON(respObj)
        self.finish()
        return


class deviceNotifyAllHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, account_id):
        self.asyncHelper(account_id)

    @run_async
    def asyncHelper(self, account_id):

        respObj = accountsCommonHandlers.device_notify_all(account_id)

        self.writeJSON(respObj)
        self.finish()
        return


class accountResetHandler(bakkleRequestHandler):

    @asynchronous
    def get(self, account_id):
        self.asyncHelper(account_id)

    @run_async
    def asyncHelper(self, account_id):

        context = accountsCommonHandlers.reset(account_id)

        self.render('templates/account/detail.html',
                    title="account",
                    account=context['account'],
                    devices=context['devices'],
                    items=context['items'],
                    selling=context['selling'],
                    item_count=context['item_count'],
                    items_sold=context['items_sold'],
                    items_viewed=context['items_viewed']
                    )
        return


class settingsHandler(bakkleRequestHandler):

    @asynchronous
    def get(self):
        self.asyncHelper()

    @run_async
    def asyncHelper(self):

        respObj = accountsCommonHandlers.settings()

        self.writeJSON(respObj)
        self.finish()
        return


class loginFacebookHandler(bakkleRequestHandler):

    def post(self):
        # TODO: Handle location
        # Get the rest of the necessary params from the request
        try:
            user_id = self.getArgument('user_id')
            device_uuid = self.getArgument('device_uuid')
            user_location = self.getArgument('user_location')
            app_version = self.getArgument('app_version')
            is_ios = self.getArgument('is_ios', True)
            client_ip = self.getIP()
            app_flavor = self.getArgument("flavor", 1)
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

        if(not self.authenticate()):
            self.writeJSON({'success': 0, 'error': 'Device not authenticated'})
            self.finish()
            return

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

        if(not self.authenticate()):
            self.writeJSON({'success': 0, 'error': 'Device not authenticated'})
            self.finish()
            return

        try:
            accountId = self.getArgument('accountId')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.get_account(accountId)

        self.writeJSON(respObj)


class logoutHandler(bakkleRequestHandler):

    def post(self):

        if(not self.authenticate()):
            self.writeJSON({'success': 0, 'error': 'Device not authenticated'})
            self.finish()
            return

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
            device_uuid = self.getArgument('device_uuid')
            app_flavor = self.getArgument('flavor', 1)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.facebook(facebook_id,
                                                  display_name,
                                                  device_uuid,
                                                  app_flavor)

        self.writeJSON(respObj)

class guestUserIdHandler(bakkleRequestHandler):

    def post(self):

        try:
            device_uuid = self.getArgument('device_uuid')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.guest_user_id(device_uuid)

        self.writeJSON(respObj)

class localUserIdHandler(bakkleRequestHandler):

    def post(self):

        try:
            device_uuid = self.getArgument('device_uuid')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.guest_user_id(device_uuid)

        self.writeJSON(respObj)


class updateProfileHandler(bakkleRequestHandler):

    def post(self):

        try:
            facebook_id = self.getArgument('user_id')
            display_name = self.getArgument('name')
            device_uuid = self.getArgument('device_uuid')
            app_flavor = self.getArgument('flavor', 1)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.update_profile(facebook_id,
                                                        display_name,
                                                        device_uuid,
                                                        app_flavor)

        self.writeJSON(respObj)

class setPasswordHandler(bakkleRequestHandler):

    def post(self):

        try:
            facebook_id = self.getArgument('user_id')
            device_uuid = self.getArgument('device_uuid')
            app_flavor = self.getArgument('flavor', 1)
            password = self.getArgument('password', 1)
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.set_password(facebook_id,
                                                      device_uuid,
                                                      app_flavor,
                                                      password)

        self.writeJSON(respObj)

class authenticateLocalHandler(bakkleRequestHandler):

    def post(self):

        try:
            facebook_id = self.getArgument('user_id')
            device_uuid = self.getArgument('device_uuid')
            app_flavor = self.getArgument('flavor', 1)
            password = self.getArgument('password')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.authenticate_local(facebook_id,
                                                            device_uuid,
                                                            app_flavor,
                                                            password)

        self.writeJSON(respObj)

class deviceRegisterPushHandler(bakkleRequestHandler):

    def post(self):

        if(not self.authenticate()):
            self.writeJSON({'success': 0, 'error': 'Device not authenticated'})
            self.finish()
            return

        try:
            account_id = self.getUser()
            device_uuid = self.getArgument('device_uuid')
            device_token = self.getArgument('device_token')
            client_ip = self.getIP()
            logging.info("device_register_push device_token={},device_uudi={}".format(device_token.replace(" ", ""),device_uuid))
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        respObj = accountsCommonHandlers.device_register_push(
            account_id,
            device_uuid,
            device_token,
            client_ip)

        self.writeJSON(respObj)
