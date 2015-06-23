# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('chat', '0002_auto_20150617_1949'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='message',
            name='closed',
        ),
        migrations.AddField(
            model_name='chat',
            name='closed',
            field=models.BooleanField(default=False),
        ),
    ]
