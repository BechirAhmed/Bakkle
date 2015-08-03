# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('chat', '0004_chat_hasunread'),
    ]

    operations = [
        migrations.RenameField(
            model_name='chat',
            old_name='hasUnread',
            new_name='hasUnreadBuyer',
        ),
        migrations.AddField(
            model_name='chat',
            name='hasUnreadSeller',
            field=models.BooleanField(default=False),
        ),
    ]
