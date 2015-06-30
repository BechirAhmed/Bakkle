# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='BuyerItem',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('view_time', models.DateTimeField(auto_now=True)),
                ('view_duration', models.DecimalField(max_digits=10, decimal_places=2)),
                ('status', models.CharField(default=b'Active', max_length=11, choices=[(b'Active', b'Active'), (b'Meh', b'Meh'), (b'Hold', b'Hold'), (b'Want', b'Want'), (b'Report', b'Report'), (b'Negotiating', b'Negotiating'), (b'Pending', b'Pending'), (b'Sold', b'Sold'), (b'Sold To', b'Sold To'), (b'My Item', b'My Item')])),
                ('confirmed_price', models.DecimalField(max_digits=7, decimal_places=2)),
                ('accepted_sale_price', models.BooleanField(default=False)),
                ('buyer', models.ForeignKey(to='account.Account')),
            ],
        ),
        migrations.CreateModel(
            name='Items',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('image_urls', models.CharField(max_length=1000)),
                ('title', models.CharField(max_length=200)),
                ('description', models.CharField(max_length=4000)),
                ('location', models.CharField(max_length=25)),
                ('price', models.DecimalField(max_digits=11, decimal_places=2)),
                ('tags', models.CharField(max_length=300)),
                ('method', models.CharField(default=b'Pick-up', max_length=11, choices=[(b'Pick-up', b'Pick-up'), (b'Delivery', b'Delivery'), (b'Meet', b'Meet'), (b'Ship', b'Ship')])),
                ('status', models.CharField(default=b'Active', max_length=11, choices=[(b'Active', b'Active'), (b'Pending', b'Pending'), (b'Sold', b'Sold'), (b'Expired', b'Expired'), (b'Spam', b'Spam'), (b'Deleted', b'Deleted')])),
                ('post_date', models.DateTimeField(auto_now_add=True)),
                ('times_reported', models.IntegerField(default=0)),
                ('seller', models.ForeignKey(to='account.Account')),
            ],
        ),
        migrations.AddField(
            model_name='buyeritem',
            name='item',
            field=models.ForeignKey(to='items.Items'),
        ),
        migrations.AlterUniqueTogether(
            name='buyeritem',
            unique_together=set([('buyer', 'item')]),
        ),
    ]
