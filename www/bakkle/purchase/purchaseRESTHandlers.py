from common.bakkleRequestHandler import bakkleRequestHandler
from common.bakkleRequestHandler import QueryArgumentError

import stripe


class inputSellerRatingRequestHandler(bakkleRequestHandler):

    def post(self):
        pass


class inputBuyerRatingRequestHandler(bakkleRequestHandler):

    def get(self):
        pass

    def post(self):
        pass


class stripeChargeHandler(bakkleRequestHandler):

    def get(self):
        self.post()

    def post(self):
        try:
            stripeToken = self.getArgument('stripeToken')
        except QueryArgumentError as error:
            return self.writeJSON({"status": 0, "message": error.message})

        # Set your secret key: remember to change this to your live key
        # See your keys here https://dashboard.stripe.com/account/apikeys
        stripe.api_key = "PRIVATE_KEY_HERE"

        # Create the charge on Stripe's servers - this will charge the user's
        # card
        try:
            charge = stripe.Charge.create(
                amount=1000,  # amount in cents, again
                currency="usd",
                source=stripeToken,
                description="Example charge"
            )
        except Exception as error:
            # The card has been declined
            return self.writeJSON({"status": 0, "message": error.message})
            pass

        self.writeJSON({'success': 1, 'charge': charge})
