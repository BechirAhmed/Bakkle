# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0005_auto_20150709_1814'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='email',
            field=models.CharField(max_length=200),
        ),
        migrations.AlterField(
            model_name='account',
            name='facebook_id',
            field=models.CharField(max_length=200),
        ),
        migrations.AlterUniqueTogether(
            name='account',
            unique_together=set([('facebook_id', 'app_flavor')]),
        ),
    ]
