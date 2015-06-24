# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('items', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='items',
            name='location',
        ),
        migrations.AddField(
            model_name='items',
            name='latitude',
            field=models.DecimalField(default=37.47, max_digits=5, decimal_places=2),
        ),
        migrations.AddField(
            model_name='items',
            name='longitude',
            field=models.DecimalField(default=122.25, max_digits=5, decimal_places=2),
        ),
    ]
