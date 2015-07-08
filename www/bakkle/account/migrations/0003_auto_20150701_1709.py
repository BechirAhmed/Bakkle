# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0002_account_app_flavor'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='app_flavor',
            field=models.IntegerField(default=1),
        ),
    ]
