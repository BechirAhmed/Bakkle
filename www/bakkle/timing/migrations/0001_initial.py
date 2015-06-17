# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Timing',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('datetime', models.DateTimeField(auto_now=True)),
                ('user', models.IntegerField()),
                ('func', models.CharField(max_length=50)),
                ('time', models.IntegerField()),
                ('args', models.CharField(max_length=500)),
            ],
        ),
    ]
