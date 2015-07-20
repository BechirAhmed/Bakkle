# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0004_account_decription'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='account',
            name='decription',
        ),
        migrations.AddField(
            model_name='account',
            name='description',
            field=models.CharField(default=None, max_length=2000, null=True),
        ),
    ]
