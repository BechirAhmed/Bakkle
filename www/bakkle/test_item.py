#!/usr/bin/python

import django
from django.conf import settings
from common.sysVars import getDATABASES

settings.configure(DATABASES=getDATABASES())

from django.db import models


from tornado.log import logging
from random import randint

from items.itemsCommonHandlers import h_validate_location
import unittest

#python -m unittest test_item.TestHelpers

class TestHelpers(unittest.TestCase):
    def test1(self):
        self.assertEqual( h_validate_location( '-83.0, 65.00' ), ("-83.0,65.0", -83.0, 65.0) )
    def test2(self):
        self.assertRaises( Exception, h_validate_location, 'dfsafd' )
    def test3(self):
        self.assertRaises( Exception, h_validate_location, '-8..3,83.0' )



if __name__ == 'main':
    unittest.main()
    suite = unittest.TestLoader().loadTestsFromTestCase(TestHelpers)
    unittest.TextTestRunner(verbosity=2).run(suite)
