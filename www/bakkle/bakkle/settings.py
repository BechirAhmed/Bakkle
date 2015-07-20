"""
Django settings for bakkle project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
from os import environ

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'mgx@!&p=om*n5y5z#09d4s1672bhp+_a_$dwtczg5xp91d3#v0'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

TEMPLATE_DEBUG = True

ALLOWED_HOSTS = []

# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'items',
    'account',
    'system',
    'timing',
    'chat',
    'common',
    'purchase'
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'bakkle.urls'

WSGI_APPLICATION = 'bakkle.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

DATABASES = {
    'default': {
    },
    'dev': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    },
    'wongb': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'wongb',
        'USER': 'root',
        'PASSWORD': 'Bakkle123',
        'HOST': 'bakkle.cw8vja43bda8.us-west-2.rds.amazonaws.com',
        'PORT': '5432',
    },
    'testdb': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'testdb',
        'USER': 'root',
        'PASSWORD': 'Bakkle123',
        'HOST': 'bakkle.cw8vja43bda8.us-west-2.rds.amazonaws.com',
        'PORT': '5432',
    },
    'production': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'bakkle',
        'USER': 'root',
        'PASSWORD': 'Bakkle123',
        'HOST': 'bakkle.cw8vja43bda8.us-west-2.rds.amazonaws.com',
        'PORT': '5432',
    }
}

default_database = environ.get('DJANGO_DATABASE', 'dev')
default_database = 'production'
DATABASES['default'] = DATABASES[default_database]

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Host for sending e-mail.
EMAIL_HOST = 'email-smtp.us-west-2.amazonaws.com'

# Port for sending e-mail.
EMAIL_PORT = '25'

# Optional SMTP authentication information for EMAIL_HOST.
EMAIL_HOST_USER = 'AKIAIWU57Q5HQBFHEYGQ'
EMAIL_HOST_PASSWORD = 'Atuz2dvDHbHZCvq7mWZF2cORjZn+XL5TFtYe2VsT2rlf'

EMAIL_USE_TLS = True
EMAIL_BACKEND = 'django_smtp_ssl.SSLEmailBackend'

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_URL = '/static/'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,  # True,
    'formatters': {
        'standard': {
            'format': "[%(asctime)s] %(levelname)s [%(name)s:%(lineno)s] %(message)s",
            'datefmt': "%d/%b/%Y %H:%M:%S"
        },
    },
    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'django.utils.log.NullHandler',
        },
        'logfile': {
            'level': 'DEBUG',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': "/var/log/bakkle.log",
            'maxBytes': 50000,
            'backupCount': 2,
            'formatter': 'standard',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'standard'
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'logfile'],
            'propagate': True,
            'level': 'WARN',
        },
        'django.db.backends': {
            'handlers': ['console', 'logfile'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'MYAPP': {
            'handlers': ['console', 'logfile'],
            'level': 'DEBUG',
        },
    }
}

import logging
log = logging.getLogger(__name__)
log.debug("System started")
