from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models

import unittest
import items.itemsCommonHandlers

class TestHelpers(unittest.TestCase):
    def test(self):
        self.assertEqual( h_validate_location( 'dfsafd' ) )

