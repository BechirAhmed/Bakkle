# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('items', '0003_buyeritem_sale'),
    ]

    operations = [
        migrations.AddField(
            model_name='buyeritem',
            name='message',
            field=models.CharField(max_length=500, null=True),
        ),
    ]
