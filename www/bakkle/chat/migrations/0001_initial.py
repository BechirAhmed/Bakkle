# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '__first__'),
    ]

    operations = [
        migrations.CreateModel(
            name='Chat',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('start_date', models.DateTimeField(auto_now_add=True)),
                ('buyer', models.ForeignKey(to='account.Account')),
            ],
        ),
        migrations.CreateModel(
            name='Message',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('sent_by_buyer', models.BooleanField(default=True)),
                ('closed', models.BooleanField(default=False)),
                ('date_sent', models.DateTimeField(auto_now_add=True)),
                ('viewed_by_buyer_time', models.DateTimeField(null=True)),
                ('viewed_by_seller_time', models.DateTimeField(null=True)),
                ('message', models.CharField(max_length=500)),
                ('proposed_price', models.DecimalField(null=True, max_digits=10, decimal_places=2)),
                ('chat', models.ForeignKey(to='chat.Chat')),
            ],
        ),
    ]
