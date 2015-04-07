# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0002_auto_20150406_1502'),
    ]

    operations = [
        migrations.AddField(
            model_name='account',
            name='displayNumItems',
            field=models.IntegerField(default=100),
        ),
        migrations.AddField(
            model_name='account',
            name='maxDistance',
            field=models.IntegerField(default=10),
        ),
        migrations.AddField(
            model_name='account',
            name='maxPrice',
            field=models.DecimalField(default=100.0, max_digits=7, decimal_places=2),
        ),
        migrations.AlterField(
            model_name='device',
            name='notificationsEnabled',
            field=models.BooleanField(default=True),
        ),
    ]
