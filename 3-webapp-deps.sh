#!/bin/sh

sudo apt-get install python-django python-pip python2.7-dev -y
sudo apt-get install postgresql-client-9.3 #convineince only
sudo apt-get install postgresql-common libpq-dev -y
sudo pip install psycopg2
sudo pip install uwsgi
sudo pip install apns
sudo pip install boto
sudo pip install tornado
sudo pip install redis
sudo pip install futures
sudo pip install python-gcm

#probably needed on ubuntus udo apt-get install libffi-dev libssl-dev
sudo pip install requests[security]
# sudo pip install django --upgrade
sudo pip install django

