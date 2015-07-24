import os
import socket

activeDB = None

def getDATABASES():
    BASE_DIR = os.path.dirname(os.path.dirname(__file__))
    DATABASES = {
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
    hostname = socket.gethostname()


    if(hostname == 'ip-172-31-21-18' or hostname == 'ip-172-31-27-192'):
        DATABASES['default'] = DATABASES['production']
        activeDB = 'production'

    elif(hostname == 'rhv-bakkle'):
        DATABASES['default'] = DATABASES['testdb']
        activeDB = 'testdb'

    elif(hostname == 'rhv-bakkle-bld' or hostname == 'rhv-lnx-291scs'):
        DATABASES['default'] = DATABASES['dev']
        activeDB = 'dev'

    return DATABASES;

def getActiveDB():
    return activeDB

def getSysVars():
    valuesDict = {
        'activeDB': activeDB,
    }
    return valuesDict
