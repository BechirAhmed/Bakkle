# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('chat', '0001_initial'),
        ('items', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='chat',
            name='item',
            field=models.ForeignKey(to='items.Items'),
        ),
        migrations.AlterUniqueTogether(
            name='chat',
            unique_together=set([('item', 'buyer')]),
        ),
    ]
