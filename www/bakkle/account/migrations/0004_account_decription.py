# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0003_auto_20150701_1709'),
    ]

    operations = [
        migrations.AddField(
            model_name='account',
            name='decription',
            field=models.CharField(max_length=2000, null=True),
        ),
    ]
