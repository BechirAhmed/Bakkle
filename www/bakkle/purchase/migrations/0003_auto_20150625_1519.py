# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('purchase', '0002_auto_20150625_1517'),
    ]

    operations = [
        migrations.AlterField(
            model_name='offer',
            name='proposed_price',
            field=models.DecimalField(null=True, max_digits=10, decimal_places=2),
        ),
    ]
