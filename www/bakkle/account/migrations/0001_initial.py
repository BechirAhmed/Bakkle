# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Account',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('email', models.CharField(unique=True, max_length=200)),
                ('password', models.CharField(max_length=20)),
                ('facebookId', models.CharField(unique=True, max_length=200)),
                ('twitterId', models.CharField(max_length=200)),
                ('displayName', models.CharField(max_length=200)),
                ('avatarImageUrl', models.CharField(max_length=200)),
                ('sellerRating', models.DecimalField(max_digits=2, decimal_places=1)),
                ('itemsSold', models.IntegerField()),
                ('buyerRating', models.DecimalField(max_digits=2, decimal_places=1)),
                ('itemsBought', models.IntegerField()),
            ],
        ),
        migrations.CreateModel(
            name='Device',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('dateAdded', models.DateTimeField(auto_now_add=True)),
                ('lastSeenDate', models.DateTimeField(auto_now=True)),
                ('apnsToken', models.CharField(max_length=64)),
                ('ipAddress', models.CharField(max_length=15)),
                ('uuid', models.CharField(max_length=36)),
                ('notificationsEnabled', models.BooleanField()),
                ('account_id', models.ForeignKey(to='account.Account')),
            ],
        ),
        migrations.AlterUniqueTogether(
            name='device',
            unique_together=set([('account_id', 'uuid')]),
        ),
    ]
