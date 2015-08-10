# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('chat', '0003_auto_20150625_1529'),
    ]

    operations = [
        migrations.AddField(
            model_name='chat',
            name='hasUnreadBuyer',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='chat',
            name='hasUnreadSeller',
            field=models.BooleanField(default=False),
        ),
    ]
