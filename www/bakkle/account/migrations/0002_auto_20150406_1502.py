# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='buyerRating',
            field=models.DecimalField(null=True, max_digits=2, decimal_places=1),
        ),
        migrations.AlterField(
            model_name='account',
            name='itemsBought',
            field=models.IntegerField(default=0),
        ),
        migrations.AlterField(
            model_name='account',
            name='itemsSold',
            field=models.IntegerField(default=0),
        ),
        migrations.AlterField(
            model_name='account',
            name='sellerRating',
            field=models.DecimalField(null=True, max_digits=2, decimal_places=1),
        ),
    ]
