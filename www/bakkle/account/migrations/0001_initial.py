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
                ('facebook_id', models.CharField(unique=True, max_length=200)),
                ('twitter_id', models.CharField(max_length=200)),
                ('display_name', models.CharField(max_length=200)),
                ('avatar_image_url', models.CharField(max_length=200)),
                ('seller_rating', models.DecimalField(null=True, max_digits=2, decimal_places=1)),
                ('items_sold', models.IntegerField(default=0)),
                ('buyer_rating', models.DecimalField(null=True, max_digits=2, decimal_places=1)),
                ('items_bought', models.IntegerField(default=0)),
                ('max_distance', models.IntegerField(default=10)),
                ('max_price', models.DecimalField(default=100.0, max_digits=7, decimal_places=2)),
                ('display_num_items', models.IntegerField(default=100)),
                ('user_location', models.CharField(max_length=25, null=True)),
                ('disabled', models.BooleanField(default=False)),
            ],
        ),
        migrations.CreateModel(
            name='Device',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('date_added', models.DateTimeField(auto_now_add=True)),
                ('last_seen_date', models.DateTimeField(auto_now=True)),
                ('apns_token', models.CharField(max_length=128)),
                ('ip_address', models.CharField(max_length=15)),
                ('uuid', models.CharField(max_length=36)),
                ('notifications_enabled', models.BooleanField(default=True)),
                ('auth_token', models.CharField(default=b'', max_length=256)),
                ('user_location', models.CharField(max_length=25, null=True)),
                ('app_version', models.IntegerField(default=1)),
                ('is_ios', models.BooleanField(default=True)),
                ('account_id', models.ForeignKey(to='account.Account')),
            ],
        ),
        migrations.AlterUniqueTogether(
            name='device',
            unique_together=set([('account_id', 'uuid')]),
        ),
    ]
