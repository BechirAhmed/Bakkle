# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('purchase', '0003_auto_20150625_1519'),
    ]

    operations = [
        migrations.AddField(
            model_name='sale',
            name='buyer_rating',
            field=models.IntegerField(null=True),
        ),
        migrations.AddField(
            model_name='sale',
            name='buyer_rating_description',
            field=models.CharField(max_length=200, null=True),
        ),
        migrations.AddField(
            model_name='sale',
            name='seller_rating',
            field=models.IntegerField(null=True),
        ),
        migrations.AddField(
            model_name='sale',
            name='seller_rating_description',
            field=models.CharField(max_length=200, null=True),
        ),
    ]
