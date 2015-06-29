# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('purchase', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='offer',
            name='proposed_price',
            field=models.DecimalField(default=None, max_digits=10, decimal_places=2),
        ),
        migrations.AlterField(
            model_name='sale',
            name='item',
            field=models.OneToOneField(to='items.Items'),
        ),
        migrations.AlterUniqueTogether(
            name='sale',
            unique_together=set([]),
        ),
    ]
