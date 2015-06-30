# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('items', '0002_auto_20150624_1744'),
        ('account', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Offer',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('sent_by_buyer', models.BooleanField(default=True)),
                ('date_sent', models.DateTimeField(auto_now_add=True)),
                ('proposed_price', models.DecimalField(null=True, max_digits=10, decimal_places=2)),
                ('proposed_method', models.CharField(default=b'Pick-up', max_length=11, choices=[(b'Pick-up', b'Pick-up'), (b'Delivery', b'Delivery'), (b'Meet', b'Meet'), (b'Ship', b'Ship')])),
                ('status', models.CharField(default=b'Active', max_length=11, choices=[(b'Active', b'Active'), (b'Retracted', b'Retracted'), (b'Accepted', b'Accepted')])),
                ('buyer', models.ForeignKey(to='account.Account')),
                ('item', models.ForeignKey(to='items.Items')),
            ],
        ),
        migrations.CreateModel(
            name='Sale',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('acceptedOffer', models.ForeignKey(to='purchase.Offer')),
                ('item', models.ForeignKey(to='items.Items')),
            ],
        ),
        migrations.AlterUniqueTogether(
            name='sale',
            unique_together=set([('item', 'acceptedOffer')]),
        ),
    ]
