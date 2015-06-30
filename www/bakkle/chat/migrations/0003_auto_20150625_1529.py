# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('purchase', '0003_auto_20150625_1519'),
        ('chat', '0002_auto_20150624_1744'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='message',
            name='proposed_price',
        ),
        migrations.AddField(
            model_name='message',
            name='offer',
            field=models.ForeignKey(blank=True, to='purchase.Offer', null=True),
        ),
    ]
