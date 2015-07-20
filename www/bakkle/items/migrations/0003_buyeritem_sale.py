# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('purchase', '0004_auto_20150707_1956'),
        ('items', '0002_auto_20150624_1744'),
    ]

    operations = [
        migrations.AddField(
            model_name='buyeritem',
            name='sale',
            field=models.ForeignKey(to='purchase.Sale', null=True),
        ),
    ]
